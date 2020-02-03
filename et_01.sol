pragma solidity >=0.5.0 <0.7.0;

contract EnergyTrading {
    address creator;
    mapping (address => uint256) public balanceOf;

    constructor() public {
        creator = msg.sender;
    }

    modifier IsCreator (address _user) {
        require(_user == creator, "User not Creator!");
        _;
    }

    function SetTk(uint256 _initialSupply) public IsCreator(msg.sender) {
        balanceOf[creator] = _initialSupply;                                            // Give the creator all initial tokens
    }

    function Deposit (address _account, uint256 _amount) public IsCreator(msg.sender) {
        balanceOf[_account] += _amount;
    }

    function Withdraw (address _account, uint256 _amount) public IsCreator(msg.sender) {
        balanceOf[_account] -= _amount;
    }

    function TransferFrom(address _from, address _to, uint256 _value) public IsCreator(msg.sender) {
        require(balanceOf[_from] >= _value, "Insufficient balance.");                   // Check if the sender has enough coins
        require(balanceOf[_to] + _value >= balanceOf[_to], "Transaction overflow!");    // Check for overflows
        balanceOf[_from] -= _value;                                                     // Subtract from the sender
        balanceOf[_to] += _value;                                                       // Add the same to the recipient
    }

    /////////////
    //   bid   //
    /////////////
    struct bid_struct {
        uint256[] volumn;
        uint256[] price;
    }
    // time => type(buy/sell) => user_address => bid_struct
    mapping (string => mapping (string => mapping (address => bid_struct))) bids;

    event bid_log(address _user, string _bid_time, string _bid_type, uint256[] _volumn, uint256[] _price);

    function bid(address _user, string memory _bid_time, string memory _bid_type, uint256[] memory _volumn, uint256[] memory _price) public IsCreator(msg.sender) {
        bids[_bid_time][_bid_type][_user] = bid_struct({
            volumn: _volumn,
            price: _price
        });
        emit bid_log(_user, _bid_time, _bid_type, _volumn, _price);
    }

    /////////////
    //   bid   //
    /////////////
    struct bid_struct {
        uint256[] volumn;
        uint256[] price;
    }
    // time => type(buy/sell) => user_address => bid_struct
    mapping (string => mapping (string => mapping (address => bid_struct))) bids;

    event bid_log(address _user, string _bid_time, string _bid_type, uint256[] _volumn, uint256[] _price);

    function bid(
        address _user,
        string memory _bid_time,
        string memory _bid_type,
        uint256[] memory _volumn,
        uint256[] memory _price
    ) public isCreator(msg.sender) {
        bids[_bid_time][_bid_type][_user] = bid_struct({
            volumn: _volumn,
            price: _price
        });
        emit bid_log(_user, _bid_time, _bid_type, _volumn, _price);
    }

    event get_log(uint256[] _volumn, uint256[] _price);

    function getBid(address _user, string memory _bid_time, string memory _bid_type) public returns(uint256[] memory, uint256[] memory){
        bid_struct memory the_bid = bids[_bid_time][_bid_type][_user];
        emit get_log(the_bid.volumn, the_bid.price);
        return (the_bid.volumn, the_bid.price);
    }

    /////////////
    //  match  //
    /////////////

    uint256[] buy_prices;
    uint256[] buy_volumes;
    address[] buy_users;
    uint256[] sell_prices;
    uint256[] sell_volumes;
    address[] sell_users;

    event array_log(uint256[] _volume, uint256[] _price, address[] _users);

    function getArrayLog() public {
        emit array_log(buy_volumes, buy_prices, buy_users);
        emit array_log(sell_volumes, sell_prices, sell_users);
    }

    function match_bids(
        address[] memory _users,
        string memory _bid_time
    ) public isCreator(msg.sender) {
        // GET DEMAND-REQUEST LINES
        _clear_match_array();                       // Clear array for each match event
        _combine_match_array(_bid_time, _users);    // Combine bids for every user
        getArrayLog();
        _sort_array();                              // sorting array
        _accumulate_array();
        getArrayLog();
        // Finding match intersection

        // Split bids by margin
    }

    function _clear_match_array() private {
        // Reset dynamic arrays for match bids
        buy_prices.length = 0;
        buy_volumes.length = 0;
        buy_users.length = 0;
        sell_prices.length = 0;
        sell_volumes.length = 0;
        sell_users.length = 0;
    }

    function _combine_match_array(
        string memory _bid_time, address[] memory _users
    ) private {
        // users' buys
        for(uint256 i = 0; i < _users.length; i++) {
            uint256[] memory prices;
            uint256[] memory volumes;
            bid_struct memory user_buy_bids = bids[_bid_time]["buy"][_users[i]];
            prices = user_buy_bids.price;
            volumes = user_buy_bids.volumn;

            for(uint256 j = 0; j < prices.length; j++) {
                buy_prices.push(prices[j]);
                buy_volumes.push(volumes[j]);
                buy_users.push(_users[i]);
            }
        }

        // users' sells
        for(uint256 i = 0; i < _users.length; i++) {
            uint256[] memory prices;
            uint256[] memory volumes;
            bid_struct memory user_sell_bids = bids[_bid_time]["sell"][_users[i]];
            prices = user_sell_bids.price;
            volumes = user_sell_bids.volumn;

            for(uint256 j = 0; j < prices.length; j++) {
                sell_prices.push(prices[j]);
                sell_volumes.push(volumes[j]);
                sell_users.push(_users[i]);
            }
        }
    }

    // insertion sort
    function _sort_array() private {
        uint256 j;
        uint256 b_price_key;
        uint256 b_volume_key;
        address b_user_key;
        for (uint256 i = 1; i < buy_prices.length; i++) {
            b_price_key = buy_prices[i];
            b_volume_key = buy_volumes[i];
            b_user_key = buy_users[i];
            j = i - 1;
            bool flag = false;
            while (j >= 0 && buy_prices[j] < b_price_key)
            {
                buy_prices[j + 1] = buy_prices[j];
                buy_volumes[j + 1] = buy_volumes[j];
                buy_users[j + 1] = buy_users[j];
                if(j == 0) {
                    flag = true;
                    break;
                } else {
                    j = j - 1;
                }
            }
            if(flag) {
                buy_prices[0] = b_price_key;
                buy_volumes[0] = b_volume_key;
                buy_users[0] = b_user_key;
            } else {
                buy_prices[j + 1] = b_price_key;
                buy_volumes[j + 1] = b_volume_key;
                buy_users[j + 1] = b_user_key;
            }
        }

        uint256 s_price_key;
        uint256 s_volume_key;
        address s_user_key;
        for (uint256 i = 1; i < sell_prices.length; i++) {
            s_price_key = sell_prices[i];
            s_volume_key = sell_volumes[i];
            s_user_key = sell_users[i];
            j = i - 1;
            bool flag = false;
            while (j >= 0 && sell_prices[j] > s_price_key)
            {
                sell_prices[j + 1] = sell_prices[j];
                sell_volumes[j + 1] = sell_volumes[j];
                sell_users[j + 1] = sell_users[j];
                if(j == 0) {
                    flag = true;
                    break;
                } else {
                    j = j - 1;
                }
            }
            if(flag) {
                sell_prices[0] = s_price_key;
                sell_volumes[0] = s_volume_key;
                sell_users[0] = s_user_key;
            } else {
                sell_prices[j + 1] = s_price_key;
                sell_volumes[j + 1] = s_volume_key;
                sell_users[j + 1] = s_user_key;
            }
        }
    }

    function _accumulate_array() private {
        uint256 curr_volume = 0;
        for (uint256 i = 0; i < buy_volumes.length; i++) {
            buy_volumes[i] += curr_volume;
            curr_volume = buy_volumes[i];
        }

        curr_volume = 0;
        for (uint256 i = 0; i < sell_volumes.length; i++) {
            sell_volumes[i] += curr_volume;
            curr_volume = sell_volumes[i];
        }
    }
}

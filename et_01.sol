pragma solidity >=0.5.0 <0.7.0;

contract EnergyTrading {
    address creator;
    mapping (address => uint256) public balanceOf;

    constructor() public {
        creator = msg.sender;
    }

    modifier isCreator (address _user) {
        require(_user == creator, "User not Creator!");
        _;
    }

    function SetTk(uint256 _initialSupply) public isCreator(msg.sender) {
        balanceOf[creator] = _initialSupply;              // Give the creator all initial tokens
    }

    function Deposit (address _account, uint256 _amount) public isCreator(msg.sender) {
        balanceOf[_account] += _amount;
    }

    function Withdraw (address _account, uint256 _amount) public isCreator(msg.sender) {
        balanceOf[_account] -= _amount;
    }

    function transferFrom(address _from, address _to, uint256 _value) public isCreator(msg.sender) {
        require(balanceOf[_from] >= _value, "Insufficient balance.");                // Check if the sender has enough coins
        require(balanceOf[_to] + _value >= balanceOf[_to], "Transaction overflow!"); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
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

    function match_bids(
        address[] memory _users,
        string memory _bid_time
    ) public isCreator(msg.sender) {
        // GET DEMAND-REQUEST LINES
        _match_clear_array();                       // Clear array for each match event
        _match_combine_array(_bid_time, _users);    // Combine bids for every user
        _bubble_sort_array();                       // Resorting array
        // _bubble_sort_array();                        // Resorting array
        // _bubble_sort_array();                        // Resorting array

        // Finding match intersection

        // Split bids by margin
    }

    function get_combine_array()
        public view returns(uint256[] memory _prices)
    {
        return buy_prices;
    }

    function _match_clear_array() private {
        // Reset dynamic arrays for match bids
        buy_prices.length = 0;
        buy_volumes.length = 0;
        buy_users.length = 0;
        sell_prices.length = 0;
        sell_volumes.length = 0;
        sell_users.length = 0;
    }

    function _match_combine_array(
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
            bid_struct memory user_buy_bids = bids[_bid_time]["sell"][_users[i]];
            prices = user_buy_bids.price;
            volumes = user_buy_bids.volumn;

            for(uint256 j = 0; j < prices.length; j++) {
                sell_prices.push(prices[j]);
                sell_volumes.push(volumes[j]);
                sell_users.push(_users[i]);
            }
        }
    }

    // bubble sort
    function _bubble_sort_array() private {
        uint256 l;
        l = buy_prices.length;
        for(uint256 i = 0; i < l; i++) {
            for(uint256 j = i+1; j < l ;j++) {
                // ascending sorting
                if(buy_prices[i] > buy_prices[j]) {
                    // buy
                    // change price
                    uint256 b_price = buy_prices[i];
                    buy_prices[i] = buy_prices[j];
                    buy_prices[j] = b_price;
                    // change volume
                    uint256 b_volume = buy_volumes[i];
                    buy_volumes[i] = buy_volumes[j];
                    buy_volumes[j] = b_volume;
                    // change user
                    address b_user = buy_users[i];
                    buy_users[i] = buy_users[j];
                    buy_users[j] = b_user;
                }
            }
        }
        l = sell_prices.length;
        for(uint256 i = 0; i < l; i++) {
            for(uint256 j = i+1; j < l ;j++) {
                // descending sorting
                if(sell_prices[i] < sell_prices[j]) {
                    // sell
                    // change price
                    uint256 s_price = sell_prices[i];
                    sell_prices[i] = sell_prices[j];
                    sell_prices[j] = s_price;
                    // change volume
                    uint256 s_volume = sell_volumes[i];
                    sell_volumes[i] = sell_volumes[j];
                    sell_volumes[j] = s_volume;
                    // change user
                    address s_user = sell_users[i];
                    sell_users[i] = sell_users[j];
                    sell_users[j] = s_user;
                }
            }
        }
    }

    // insertion sort
    function _insertion_sort_array() private {
        uint256 l;
        uint256 j;

        l = buy_prices.length;
        uint256 b_price_key;
        uint256 b_volume_key;
        address b_user_key;
        for (uint256 i = 1; i < l; i++) {
            b_price_key = buy_prices[i];
            j = i - 1;
            while (j >= 0 && buy_prices[j] > b_price_key)
            {
                buy_prices[j + 1] = buy_prices[j];
                buy_volumes[j + 1] = buy_volumes[j];
                buy_users[j + 1] = buy_users[j];
                j = j - 1;
            }
            buy_prices[j + 1] = b_price_key;
            buy_volumes[j + 1] = b_volume_key;
            buy_users[j + 1] = b_user_key;
        }

        l = sell_prices.length;
        uint256 s_price_key;
        uint256 s_volume_key;
        address s_user_key;
        for (uint256 i = 1; i < l; i++) {
            s_price_key = sell_prices[i];
            j = i - 1;
            while (j >= 0 && sell_prices[j] > s_price_key)
            {
                sell_prices[j + 1] = sell_prices[j];
                sell_volumes[j + 1] = sell_volumes[j];
                sell_users[j + 1] = sell_users[j];
                j = j - 1;
            }
            sell_prices[j + 1] = s_price_key;
            sell_volumes[j + 1] = s_volume_key;
            sell_users[j + 1] = s_user_key;
        }
    }
}

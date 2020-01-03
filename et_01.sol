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
}

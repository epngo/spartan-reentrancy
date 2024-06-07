pragma solidity 0.8.17;

contract VulnerableBAnk {
    mapping(address => uint256) public balances;
    uint public totalBalance;
    
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(isAllowedToWithdraw(msg.sender, amount), "Insufficient balance");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
    }
    
    function isAllowedToWithdraw(address user, uint256 amount) public view returns (bool) {
        return balances[user] >= amount;
    }
}
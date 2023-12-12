pragma solidity ^0.8.0;

contract BankAccount {
    address public owner;
    uint public balance;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balance += msg.value;
    }

    function withdraw(uint amount) public {
        require(amount <= balance, "Insufficient balance");
        require(msg.sender == owner, "Only owner can withdraw");
        balance -= amount;
        payable(msg.sender).transfer(amount);
    }
}

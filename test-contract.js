"use strict";

// let Client = require('./client.js');

// Maybe this should extend block?
// module.exports = class Reentrancy extends Block{
// module.exports = class Reentrancy extends Client{
module.exports = class Reentrancy {
    contract = {
        depositFunds: {
            balances: new Map(),
            deposit() {
                // Simulate deposit function
                const value = 1;
                const sender = tx.from;

                if (!this.balances.has(sender)) {
                    this.balances.set(sender, 0);
                }

                this.balances.set(sender, this.balances.get(sender) + value);
            },
            withdraw() {
                // Simulate withdraw function
                const sender = tx.from;
                const bal = this.balances.get(sender);
                if (bal > 0) {
                    // Simulate transfer
                    const sent = this.transfer(sender, bal);
                    if (sent) {
                        this.balances.set(sender, 0);
                    }
                }
            },
        },
    }
    

    // Call the vulnerable contract's function
    executeVulnerableFunction(vulnerableContract, contractAddress, attackerContract) {
        SpartanScriptInterpreter.execute(
            vulnerableContract + tx.data.call,
            {
                // Pass the current block state to the interpreter
                block: this,
                // Pass the reentrant function as a callback
                reentrantCallback: reentrancy.bind(attackerContract),
            }
        );

        // Check the balances
        console.log("Contract balance: " + this.balanceOf(contractAddress));
        console.log("Attacker balance: " + this.balanceOf(tx.from));

        // After the reentrancy call, check if the contract was successfully drained
        if (attackerContract.depositFunds.balances.get(contractAddress) === 0) {
            console.log(`Reentrancy attack successful!`);
        }
    }

    reentrancy() {
        // Repeatedly call this function and drain the contract's balance
        if (this.depositFunds.balances.has(tx.from)) {
            // Deposit to the attacker's contract
            this.depositFunds.deposit();
            // Withdraw from the vulnerable contract
            this.depositFunds.withdraw();
        }
    }
};
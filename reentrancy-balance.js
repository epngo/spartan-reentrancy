module.exports = class depositFunds {
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
}
(define (secured-contract)
(define balances (make-hash))
(define total-balance 0)

(define (deposit)
    (let ((amount (message-data)))
        (assert (> amount 0) "Deposit amount must be greater than 0")
        (hash-set! balances (sender) (+ (hash-ref balances (sender) 0) amount))))

(define (withdraw)
    (let ((amount (message-data)))
        (assert (> amount 0) "Withdraw amount must be greater than 0")
        (assert (is-allowed-to-withdraw (sender) amount) "Insufficient balance")
        (hash-set! balances (sender) (- (hash-ref balances (sender) 0) amount))
        (assert (transfer (sender) amount) "Transfer failed")))

(define (is-allowed-to-withdraw user amount)
  (>= (hash-ref balances user 0) amount))


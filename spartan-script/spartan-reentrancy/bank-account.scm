(provide totalSupply balanceOf allowance transfer approve transferFrom)

(define totalSupply 0)
(define balances (make-hash)) ; Hash table to store account balances
(define allowed (make-hash)) ; Hash table to store allowed transfers

(define balanceOf
  (lambda (addr)
    (hash-ref balances addr 0)))

(define transfer
  (lambda (receiver tokens)
    (begin
      (require (>= (balanceOf $sender) tokens))
      (hash-set! balances $sender (- (balanceOf $sender) tokens))
      (hash-set! balances receiver (+ tokens (balanceOf receiver)))
      #t)))

(define allowance
  (lambda (owner spender)
    (hash-ref (hash-ref allowed owner (make-hash)) spender 0)))

(define approve
  (lambda (spender tokens)
    (hash-set! (hash-ref allowed $sender (make-hash)) spender tokens)
    #t))

(define transferFrom
  (lambda (owner receiver tokens)
    (begin
      (require (>= (balanceOf owner) tokens))
      (require (>= (allowance owner $sender) tokens))
      (hash-set! balances owner (- (balanceOf owner) tokens))
      (hash-set! (hash-ref allowed owner (make-hash)) $sender (- (allowance owner $sender) tokens))
      (hash-set! balances receiver (+ tokens (balanceOf receiver)))
      #t))
)
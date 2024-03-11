(define balances (make-hash)) ; Mapping from address to balance
(define locked? #f) ; Lock

(define (deposit sender value)
  (hash-update! balances sender (lambda (old-balance) (+ old-balance value))))

(define (withdraw sender)
  (when (not locked?)
    (let ((bal (hash-ref balances sender 0)))
      (when (> bal 0)
        (set! locked? #t) ; Acquire the lock
        (let-values (((sent _) (call sender bal)))
          (unless sent
            (error "Failed to send SpartanGold")))
        (hash-set! balances sender 0)
        (set! locked? #f))))) ; Release the lock

; the withdraw function has locks to prevent reentrancy attacks by preventing changes when calls are made
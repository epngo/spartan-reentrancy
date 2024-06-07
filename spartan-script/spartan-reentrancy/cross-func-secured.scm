(define (make-ReentrancyGuard)
  (let ((locked #f))
    (define (noReentrant thunk)
      (assert (not locked) "No re-entrancy")
      (set! locked #t)
      (thunk)
      (set! locked #f)))

    (record
      (noReentrant noReentrant)
      (locked locked)))

(define (make-CrossFuncGuard)
  (let ((user-balances (make-hash))
    (reentrancy-guard (make-ReentrancyGuard)))
    (define (deposit)
      (hash-update! user-balances (msg.sender) (lambda (balance) (+ balance (msg.value)))))

    (define (transfer _to _amount)
      (let ((from-balance (hash-ref user-balances (msg.sender) 0)))
        (when (>= from-balance _amount)
          (hash-update! user-balances _to (lambda (balance) (+ balance _amount)))
          (hash-update! user-balances (msg.sender) (lambda (balance) (- balance _amount))))))

    (define (withdrawAll)
      ; Use reentrancy-guard to protect against re-entrancy
      ((reentrancy-guard 'noReentrant)
       (let ((balance (getUserBalance (msg.sender))))
          (assert (> balance 0) "Insufficient balance")
          ; This line gets moves so it happens before the sender call
          (hash-set! user-balances (msg.sender) 0)
          (let ((success (send (msg.sender) 'call (list 'value balance) "")))
            (assert success "Failed to send Token")))))

    (define (getBalance)
      (address.this 'balance))

    (define (getUserBalance _user)
      (hash-ref user-balances _user 0))

    (record
      (deposit deposit)
      (transfer transfer)
      (withdrawAll withdrawAll)
      (getBalance getBalance)
      (getUserBalance getUserBalance))))

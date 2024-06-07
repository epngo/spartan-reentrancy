(define (make-CrossFuncVulnerable)
  (let ((user-balances (make-hash)) 
    (reentrancy-guard (make-ReentrancyGuard))) 
    (define (deposit)
      (hash-update! user-balances (msg.sender) (lambda (balance) (+ balance (msg.value)))))

    (define (transfer _to _amount)
      (let ((from-balance (hash-ref user-balances (msg.sender) 0)))
        (when (>= from-balance _amount)
          (hash-update! user-balances _to (lambda (balance) (+ balance _amount)))
          (hash-update! user-balances (msg.sender) (lambda (balance) (- balance _amount))))))

    ; Define function to withdraw all funds
    (define (withdrawAll)
      ; The reentrancy guard doesn't fully
      ; protect against vulnerabilities here
      ((reentrancy-guard 'noReentrant) 
        ; This section is not atomic, vulnerability arises here
        (let ((balance (getUserBalance (msg.sender))))
          (assert (> balance 0) "Insufficient balance")
          (let ((success (send (msg.sender) 'call (list 'value balance) "")))
            (assert success "Failed to send Token"))
						; This external call gets exploited
            (hash-set! user-balances (msg.sender) 0)))) 

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

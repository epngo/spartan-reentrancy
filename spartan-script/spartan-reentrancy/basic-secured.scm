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

(define DepositFunds
  (let ((balances (make-hash-table)))
    (reentrancy-guard (make-ReentrancyGuard)))
      (lambda (msg)
        (case (car msg)
        
          ((deposit)
          (let* ((sender (cadr msg))
                  (value (caddr msg)))
            (hash-table-update! balances sender (lambda (balance) (+ balance value)))
            'deposit-successful))

          ((withdraw)
          (let* ((sender (cadr msg))
                  (bal (hash-table-ref balances sender)))
            (if (> bal 0)
                (begin
                  (hash-table-update! balances sender (lambda (_) 0))
                  (list #t bal))
                #f))))))

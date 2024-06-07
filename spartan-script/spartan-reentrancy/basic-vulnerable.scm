(define DepositFunds
  (let ((balances (make-hash-table)))
    (lambda (msg)
      (case (car msg)
      
        ((deposit)
         (let* ((sender (cadr msg)) (value (caddr msg)))
           (hash-table-update! balances sender (lambda (balance) (+ balance value)))
           'deposit-successful))

        ((withdraw)
         (let* ((sender (cadr msg))
                (bal (hash-table-ref balances sender)))
           (if (> bal 0)
               (begin
                 (hash-table-update! balances sender (lambda (_) 0))
                 (list #t bal))
               #f)))))))
(define DepositFunds
  (let ((balances (make-hash)))
    (lambda (msg)
      (case (car msg)
        ((deposit)
         (hash-set! balances (cadr msg)
                   (+ (hash-ref balances (cadr msg) 0) (caddr msg))))
        ((withdraw)
         (let ((bal (hash-ref balances (cadr msg) 0)))
           (when (> bal 0)
             (let ((sent #t))
               (if (< (vector-length (cdr msg)) 2)
                   (set! sent (vector-ref (cdr msg) 1)))
               (if sent
                   (begin
                     (hash-set! balances (cadr msg) 0)
                     #t)
                   #f)))))))))


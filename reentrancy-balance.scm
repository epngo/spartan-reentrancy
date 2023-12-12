(define (make-account initial-balance)
  (let ((balance initial-balance))
    (define (deposit amount)
      (set! balance (+ balance amount))
      balance)
    
    (define (withdraw amount)
      (if (>= balance amount)
          (begin
            (set! balance (- balance amount))
            balance)
          "Insufficient funds"))
    
    (define (get-balance)
      balance)
    
    (define (dispatch m)
      (cond ((eq? m 'deposit) deposit)
            ((eq? m 'withdraw) withdraw)
            ((eq? m 'balance) get-balance)
            (else (error "Unknown operation -- ACCOUNT" m))))
    
    dispatch))
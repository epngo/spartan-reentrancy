; re-entrancy fefense 
(define-syntax-rule (no-reentrant body)
  (if (not locked)
      (begin
        (set! locked #t)
        body
        (set! locked #f))
      (error "No re-entrancy")))

(define (deposit-funds-deposit)
  (let ((balances (make-hash)))
    (lambda (sender value)
      (let ((current-balance (hash-ref balances sender 0)))
        (hash-set! balances sender (+ current-balance value))))))

(define (deposit-funds-withdraw)
  (let ((balances (make-hash)))
    (lambda (sender)
      (let ((balance (hash-ref balances sender 0)))
        (if (> balance 0)
            (begin
              (hash-set! balances sender 0)))))))


(define deposit-funds
  (let ((balances (make-hash)))
    (lambda ()
      (let ((deposit (deposit-funds-deposit))
            (withdraw (deposit-funds-withdraw)))
        (define (get-balance address)
          (hash-ref balances address 0))

        (define (set-balance! address value)
          (hash-set! balances address value))

        (define (deposit-function)
          (lambda (sender value)
            (let ((current-balance (get-balance sender)))
              (set-balance! sender (+ current-balance value)))))

        (define (withdraw-function)
          (lambda (sender)
            (let ((balance (get-balance sender)))
              (if (> balance 0)
                  (begin
                    ; Emulate call to msg.sender.call{value: balance}("")
                    (display "Sending Ether to sender")
                    (set-balance! sender 0))
                  (error "Failed to send Ether")))))

        (list deposit-function withdraw-function)))))

(define attack
  (let ((deposit-funds-instance (deposit-funds)))
    (lambda (deposit-funds-address)
      (let ((deposit-funds-instance (deposit-funds))
            (fallback (lambda ())))
        (set! deposit-funds deposit-funds-instance)

        (define (attack-function value)
          (if (>= value 1)
              (begin
                ((car deposit-funds-instance) (list 'sender value))
                ((cadr deposit-funds-instance) (list 'sender))))))

        (define (fallback-function)
          (if (>= (deposit-funds-instance) 'balance 1)
              ((cadr deposit-funds-instance) (list 'sender))))

        (list deposit-funds-instance attack-function fallback-function))))


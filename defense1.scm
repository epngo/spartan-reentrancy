(define locked #f)

(define (no-reentrancy proc)
  (lambda args
    (if (not locked)
        (begin
          (set! locked #t)
          (let ((result (apply proc args)))
            (set! locked #f)
            result))
        (error "ReentrancyGuard: reentrant call"))))

(define (vulnerable-function)
; reentrancy-balance.scm stuff

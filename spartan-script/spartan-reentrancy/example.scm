(provide getgold balance)

(define getgold 
    (lambda (amt dest) 
    ($transfer amt dest)))
    
(define balance 
    (lambda () 
    ($balance $me)))
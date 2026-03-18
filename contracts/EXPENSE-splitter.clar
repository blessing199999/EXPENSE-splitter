;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SHARED EXPENSE SPLITTER
;;
;; ---------------------------------------------------------------------------
;; OVERVIEW
;; ---------------------------------------------------------------------------
;; This contract allows a group of participants to split a shared expense.
;;
;; Example use case:
;; A group of friends pays for dinner. One person pays the bill, and the
;; contract records how much each participant owes.
;;
;; The contract calculates the equal share and tracks payments made by
;; participants until the expense is fully settled.
;;
;; ---------------------------------------------------------------------------
;; FEATURES
;; ---------------------------------------------------------------------------
;; - Track total shared expense
;; - Register participants
;; - Compute equal share for each participant
;; - Allow participants to settle their payment
;; - Track payment completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; ============================================================================
;; SECTION 1 - CONTRACT OWNER
;; ============================================================================

;; The contract deployer becomes the owner.
;; The owner typically represents the person who paid the original expense.

(define-data-var contract-owner principal tx-sender)

(define-private (is-owner (who principal))
  (is-eq who (var-get contract-owner))
)



;; ============================================================================
;; SECTION 2 - EXPENSE STORAGE
;; ============================================================================

;; Total expense amount (in microSTX)

(define-data-var total-expense uint u0)

;; Total number of participants

(define-data-var participant-count uint u0)

;; Equal share each participant must pay

(define-data-var share-per-person uint u0)



;; ============================================================================
;; SECTION 3 - PARTICIPANT REGISTRY
;; ============================================================================

;; Stores all participants

(define-map participants
  { id: uint }
  { member: principal }
)

;; Tracks whether a participant has paid

(define-map payments
  { member: principal }
  { paid: bool }
)



;; ============================================================================
;; SECTION 4 - ERROR CONSTANTS
;; ============================================================================

(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-PARTICIPANT (err u101))
(define-constant ERR-ALREADY-PAID (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))



;; ============================================================================
;; SECTION 5 - ADD PARTICIPANT
;; ============================================================================

;; The owner adds participants who share the expense.

(define-public (add-participant (member principal))
  (begin

    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)

    (let
      (
        (id (var-get participant-count))
      )

      (map-set participants
        { id: id }
        { member: member }
      )

      (map-set payments
        { member: member }
        { paid: false }
      )

      (var-set participant-count (+ id u1))

      (ok true)
    )
  )
)



;; ============================================================================
;; SECTION 6 - SET TOTAL EXPENSE
;; ============================================================================

;; Owner records the total bill amount.

(define-public (set-expense (amount uint))
  (begin

    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (let
      (
        (count (var-get participant-count))
      )

      (asserts! (> count u0) ERR-INVALID-AMOUNT)

      ;; Calculate equal share
      (var-set share-per-person (/ amount count))

      ;; Store total expense
      (var-set total-expense amount)

      (ok amount)
    )
  )
)



;; ============================================================================
;; SECTION 7 - PAY SHARE
;; ============================================================================

;; Participants send their share to the owner.

(define-public (pay-share)
  (begin

    (let
      (
        (payment (map-get? payments { member: tx-sender }))
      )

      ;; Ensure user is part of the expense
      (asserts! (is-some payment) ERR-NOT-PARTICIPANT)

      ;; Ensure they haven't paid yet
      (asserts!
        (not (get paid (unwrap-panic payment)))
        ERR-ALREADY-PAID
      )

      ;; Transfer share to owner
      (try!
        (stx-transfer?
          (var-get share-per-person)
          tx-sender
          (var-get contract-owner)
        )
      )

      ;; Mark as paid
      (map-set payments
        { member: tx-sender }
        { paid: true }
      )

      (ok true)
    )
  )
)



;; ============================================================================
;; SECTION 8 - READ-ONLY FUNCTIONS
;; ============================================================================

;; Returns total expense

(define-read-only (get-total-expense)
  (var-get total-expense)
)

;; Returns individual share amount

(define-read-only (get-share-per-person)
  (var-get share-per-person)
)

;; Returns number of participants

(define-read-only (get-participant-count)
  (var-get participant-count)
)

;; Check if participant has paid

(define-read-only (has-paid (member principal))
  (match (map-get? payments { member: member })
    entry (get paid entry)
    false
  )
)
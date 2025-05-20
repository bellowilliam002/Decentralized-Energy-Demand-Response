;; utility-verification.clar
;; This contract validates energy providers

(define-data-var contract-owner principal tx-sender)

;; Map to store verified utilities
(define-map verified-utilities principal {
  name: (string-utf8 100),
  registration-time: uint,
  active: bool
})

;; Error codes
(define-constant err-not-owner (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))

;; Check if caller is contract owner
(define-private (is-owner)
  (is-eq tx-sender (var-get contract-owner))
)

;; Register a new utility
(define-public (register-utility (utility-address principal) (utility-name (string-utf8 100)))
  (begin
    (asserts! (is-owner) err-not-owner)
    (asserts! (is-none (map-get? verified-utilities utility-address)) err-already-verified)
    (ok (map-set verified-utilities utility-address {
      name: utility-name,
      registration-time: block-height,
      active: true
    }))
  )
)

;; Deactivate a utility
(define-public (deactivate-utility (utility-address principal))
  (begin
    (asserts! (is-owner) err-not-owner)
    (asserts! (is-some (map-get? verified-utilities utility-address)) err-not-verified)
    (match (map-get? verified-utilities utility-address)
      utility-data (ok (map-set verified-utilities utility-address
        (merge utility-data { active: false })))
      err-not-verified
    )
  )
)

;; Check if a utility is verified
(define-read-only (is-verified-utility (utility-address principal))
  (match (map-get? verified-utilities utility-address)
    utility-data (get active utility-data)
    false
  )
)

;; Get utility details
(define-read-only (get-utility-details (utility-address principal))
  (map-get? verified-utilities utility-address)
)

;; Transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-owner) err-not-owner)
    (ok (var-set contract-owner new-owner))
  )
)

;; Content Creator Verification Contract
;; Manages content creator identity verification and profiles

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-creator-not-found (err u101))
(define-constant err-creator-already-exists (err u102))
(define-constant err-invalid-creator-id (err u103))
(define-constant err-verification-failed (err u104))
(define-constant err-unauthorized (err u105))

;; Data Variables
(define-data-var next-creator-id uint u1)
(define-data-var contract-paused bool false)

;; Data Maps
(define-map creators
  uint
  {
    name: (string-ascii 50),
    wallet-address: principal,
    email-hash: (buff 32),
    metadata-uri: (string-ascii 200),
    verification-status: (string-ascii 20),
    reputation-score: uint,
    created-at: uint,
    updated-at: uint,
    total-content: uint,
    total-earnings: uint
  })

(define-map creator-by-wallet
  principal
  uint)

(define-map verified-creators
  uint
  bool)

(define-map creator-permissions
  uint
  {
    can-create-content: bool,
    can-transfer-licenses: bool,
    can-set-royalties: bool,
    verified-by: (optional principal)
  })

;; Read-only functions
(define-read-only (get-creator-info (creator-id uint))
  (map-get? creators creator-id))

(define-read-only (get-creator-by-wallet (wallet principal))
  (map-get? creator-by-wallet wallet))

(define-read-only (is-creator-verified (creator-id uint))
  (default-to false (map-get? verified-creators creator-id)))

(define-read-only (get-creator-permissions (creator-id uint))
  (map-get? creator-permissions creator-id))

(define-read-only (get-next-creator-id)
  (var-get next-creator-id))

(define-read-only (is-contract-paused)
  (var-get contract-paused))

(define-read-only (get-creator-stats (creator-id uint))
  (match (map-get? creators creator-id)
    creator-data (ok {
      total-content: (get total-content creator-data),
      total-earnings: (get total-earnings creator-data),
      reputation-score: (get reputation-score creator-data),
      verification-status: (get verification-status creator-data)
    })
    (err err-creator-not-found)))

;; Public functions
(define-public (register-creator (name (string-ascii 50)) (email-hash (buff 32)) (metadata-uri (string-ascii 200)))
  (let (
    (creator-id (var-get next-creator-id))
    (caller tx-sender)
  )
    (asserts! (not (var-get contract-paused)) (err u106))
    (asserts! (is-none (map-get? creator-by-wallet caller)) err-creator-already-exists)
    (asserts! (> (len name) u0) (err u107))

    ;; Create creator record
    (map-set creators creator-id {
      name: name,
      wallet-address: caller,
      email-hash: email-hash,
      metadata-uri: metadata-uri,
      verification-status: "pending",
      reputation-score: u0,
      created-at: block-height,
      updated-at: block-height,
      total-content: u0,
      total-earnings: u0
    })

    ;; Map wallet to creator ID
    (map-set creator-by-wallet caller creator-id)

    ;; Set initial permissions
    (map-set creator-permissions creator-id {
      can-create-content: true,
      can-transfer-licenses: false,
      can-set-royalties: false,
      verified-by: none
    })

    ;; Increment next creator ID
    (var-set next-creator-id (+ creator-id u1))

    (ok creator-id)))

(define-public (verify-creator (creator-id uint))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) (err u106))

    ;; Update creator verification status
    (map-set creators creator-id (merge creator-data {
      verification-status: "verified",
      updated-at: block-height
    }))

    ;; Mark as verified
    (map-set verified-creators creator-id true)

    ;; Update permissions
    (map-set creator-permissions creator-id {
      can-create-content: true,
      can-transfer-licenses: true,
      can-set-royalties: true,
      verified-by: (some tx-sender)
    })

    (ok true)))

(define-public (update-creator-profile (creator-id uint) (metadata-uri (string-ascii 200)))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    (asserts! (is-eq tx-sender (get wallet-address creator-data)) err-unauthorized)
    (asserts! (not (var-get contract-paused)) (err u106))

    ;; Update creator metadata
    (map-set creators creator-id (merge creator-data {
      metadata-uri: metadata-uri,
      updated-at: block-height
    }))

    (ok true)))

(define-public (update-reputation-score (creator-id uint) (new-score uint))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) (err u106))
    (asserts! (<= new-score u100) (err u108))

    ;; Update reputation score
    (map-set creators creator-id (merge creator-data {
      reputation-score: new-score,
      updated-at: block-height
    }))

    (ok true)))

(define-public (increment-content-count (creator-id uint))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    ;; Only allow calls from verified contracts (in real implementation)
    (asserts! (not (var-get contract-paused)) (err u106))

    ;; Increment total content count
    (map-set creators creator-id (merge creator-data {
      total-content: (+ (get total-content creator-data) u1),
      updated-at: block-height
    }))

    (ok true)))

(define-public (add-earnings (creator-id uint) (amount uint))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    ;; Only allow calls from verified contracts (in real implementation)
    (asserts! (not (var-get contract-paused)) (err u106))

    ;; Add to total earnings
    (map-set creators creator-id (merge creator-data {
      total-earnings: (+ (get total-earnings creator-data) amount),
      updated-at: block-height
    }))

    (ok true)))

(define-public (revoke-verification (creator-id uint))
  (let (
    (creator-data (unwrap! (map-get? creators creator-id) err-creator-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get contract-paused)) (err u106))

    ;; Update verification status
    (map-set creators creator-id (merge creator-data {
      verification-status: "revoked",
      updated-at: block-height
    }))

    ;; Remove from verified creators
    (map-delete verified-creators creator-id)

    ;; Update permissions
    (map-set creator-permissions creator-id {
      can-create-content: false,
      can-transfer-licenses: false,
      can-set-royalties: false,
      verified-by: none
    })

    (ok true)))

;; Admin functions
(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused true)
    (ok true)))

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused false)
    (ok true)))

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; In a real implementation, this would require a more complex ownership transfer mechanism
    (ok true)))

(define-fungible-token dao-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-employee (err u101))
(define-constant err-already-employee (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-insufficient-balance (err u104))
(define-constant err-proposal-not-found (err u105))
(define-constant err-already-voted (err u106))
(define-constant err-proposal-expired (err u107))
(define-constant err-proposal-not-ended (err u108))
(define-constant err-proposal-failed (err u109))
(define-constant err-no-revenue (err u110))

(define-data-var total-employees uint u0)
(define-data-var total-productivity uint u0)
(define-data-var revenue-pool uint u0)
(define-data-var proposal-count uint u0)
(define-data-var min-proposal-tokens uint u1000)

(define-map employees principal {
    productivity-score: uint,
    join-block: uint,
    is-active: bool,
    tokens-earned: uint,
    revenue-claimed: uint
})

(define-map productivity-records {employee: principal, period: uint} uint)

(define-map proposals uint {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    proposal-type: (string-ascii 50)
})

(define-map votes {proposal-id: uint, voter: principal} bool)

(define-read-only (get-employee (employee principal))
    (map-get? employees employee)
)

(define-read-only (get-productivity-record (employee principal) (period uint))
    (default-to u0 (map-get? productivity-records {employee: employee, period: period}))
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-balance (account principal))
    (ok (ft-get-balance dao-token account))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply dao-token))
)

(define-read-only (get-revenue-pool)
    (ok (var-get revenue-pool))
)

(define-read-only (get-total-employees)
    (ok (var-get total-employees))
)

(define-read-only (calculate-revenue-share (employee principal))
    (let (
        (employee-data (unwrap! (map-get? employees employee) (err u0)))
        (employee-tokens (get tokens-earned employee-data))
        (total-supply (ft-get-supply dao-token))
        (pool (var-get revenue-pool))
    )
    (if (is-eq total-supply u0)
        (ok u0)
        (ok (/ (* employee-tokens pool) total-supply))
    ))
)

(define-public (register-employee (employee principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? employees employee)) err-already-employee)
        (map-set employees employee {
            productivity-score: u0,
            join-block: stacks-block-height,
            is-active: true,
            tokens-earned: u0,
            revenue-claimed: u0
        })
        (var-set total-employees (+ (var-get total-employees) u1))
        (ok true)
    )
)

(define-public (deactivate-employee (employee principal))
    (let (
        (employee-data (unwrap! (map-get? employees employee) err-not-employee))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set employees employee (merge employee-data {is-active: false}))
        (ok true)
    )
)

(define-public (record-productivity (employee principal) (score uint) (period uint))
    (let (
        (employee-data (unwrap! (map-get? employees employee) err-not-employee))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (get is-active employee-data) err-not-employee)
        (asserts! (> score u0) err-invalid-amount)
        (map-set productivity-records {employee: employee, period: period} score)
        (let (
            (new-productivity (+ (get productivity-score employee-data) score))
        )
            (map-set employees employee (merge employee-data {productivity-score: new-productivity}))
            (var-set total-productivity (+ (var-get total-productivity) score))
            (ok true)
        )
    )
)

(define-public (mint-tokens-for-productivity (employee principal) (amount uint))
    (let (
        (employee-data (unwrap! (map-get? employees employee) err-not-employee))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (get is-active employee-data) err-not-employee)
        (asserts! (> amount u0) err-invalid-amount)
        (try! (ft-mint? dao-token amount employee))
        (map-set employees employee (merge employee-data {
            tokens-earned: (+ (get tokens-earned employee-data) amount)
        }))
        (ok true)
    )
)

(define-public (add-revenue (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> amount u0) err-invalid-amount)
        (var-set revenue-pool (+ (var-get revenue-pool) amount))
        (ok true)
    )
)

(define-public (claim-revenue-share)
    (let (
        (employee-data (unwrap! (map-get? employees tx-sender) err-not-employee))
        (share (unwrap! (calculate-revenue-share tx-sender) err-no-revenue))
    )
        (asserts! (get is-active employee-data) err-not-employee)
        (asserts! (> share u0) err-no-revenue)
        (map-set employees tx-sender (merge employee-data {
            revenue-claimed: (+ (get revenue-claimed employee-data) share)
        }))
        (var-set revenue-pool (- (var-get revenue-pool) share))
        (ok share)
    )
)

(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (duration uint) (proposal-type (string-ascii 50)))
    (let (
        (employee-data (unwrap! (map-get? employees tx-sender) err-not-employee))
        (proposer-balance (ft-get-balance dao-token tx-sender))
        (proposal-id (+ (var-get proposal-count) u1))
    )
        (asserts! (get is-active employee-data) err-not-employee)
        (asserts! (>= proposer-balance (var-get min-proposal-tokens)) err-insufficient-balance)
        (asserts! (> duration u0) err-invalid-amount)
        (map-set proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            start-block: stacks-block-height,
            end-block: (+ stacks-block-height duration),
            yes-votes: u0,
            no-votes: u0,
            executed: false,
            proposal-type: proposal-type
        })
        (var-set proposal-count proposal-id)
        (ok proposal-id)
    )
)

(define-public (vote-on-proposal (proposal-id uint) (vote-yes bool))
    (let (
        (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
        (employee-data (unwrap! (map-get? employees tx-sender) err-not-employee))
        (voter-tokens (ft-get-balance dao-token tx-sender))
    )
        (asserts! (get is-active employee-data) err-not-employee)
        (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender})) err-already-voted)
        (asserts! (< stacks-block-height (get end-block proposal)) err-proposal-expired)
        (asserts! (> voter-tokens u0) err-insufficient-balance)
        (map-set votes {proposal-id: proposal-id, voter: tx-sender} vote-yes)
        (if vote-yes
            (map-set proposals proposal-id (merge proposal {yes-votes: (+ (get yes-votes proposal) voter-tokens)}))
            (map-set proposals proposal-id (merge proposal {no-votes: (+ (get no-votes proposal) voter-tokens)}))
        )
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let (
        (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
    )
        (asserts! (>= stacks-block-height (get end-block proposal)) err-proposal-not-ended)
        (asserts! (not (get executed proposal)) err-proposal-failed)
        (asserts! (> (get yes-votes proposal) (get no-votes proposal)) err-proposal-failed)
        (map-set proposals proposal-id (merge proposal {executed: true}))
        (ok true)
    )
)

(define-public (transfer-tokens (amount uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-owner-only)
        (asserts! (> amount u0) err-invalid-amount)
        (ft-transfer? dao-token amount sender recipient)
    )
)

(define-public (update-min-proposal-tokens (new-min uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> new-min u0) err-invalid-amount)
        (var-set min-proposal-tokens new-min)
        (ok true)
    )
)

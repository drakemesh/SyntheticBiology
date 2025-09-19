
;; title: SyntheticBiology
;; version: 1.0.0
;; summary: A synthetic assets smart contract for bioengineering and synthetic organism development exposure
;; description: This contract manages synthetic biological assets, bioengineering projects, and provides exposure to synthetic organism development

;; traits
;;

;; token definitions
(define-fungible-token syn-bio-token)

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-PROJECT-NOT-FOUND (err u103))
(define-constant ERR-PROJECT-ALREADY-EXISTS (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-PROJECT-INACTIVE (err u106))

;; data vars
(define-data-var next-project-id uint u1)
(define-data-var total-projects uint u0)
(define-data-var contract-paused bool false)

;; data maps
(define-map projects
    { project-id: uint }
    {
        name: (string-ascii 50),
        description: (string-ascii 200),
        creator: principal,
        funding-goal: uint,
        current-funding: uint,
        token-allocation: uint,
        active: bool,
        created-at: uint
    }
)

(define-map user-investments
    { user: principal, project-id: uint }
    { amount: uint, tokens-received: uint }
)

(define-map project-investors
    { project-id: uint, investor: principal }
    { investment-amount: uint }
)

(define-map user-balances
    { user: principal }
    { balance: uint }
)

;; public functions

;; Initialize contract and mint initial tokens to owner
(define-public (initialize (initial-supply uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (try! (ft-mint? syn-bio-token initial-supply CONTRACT-OWNER))
        (ok true)
    )
)

;; Create a new bioengineering project
(define-public (create-project (name (string-ascii 50)) (description (string-ascii 200)) (funding-goal uint) (token-allocation uint))
    (let
        (
            (project-id (var-get next-project-id))
        )
        (asserts! (> funding-goal u0) ERR-INVALID-AMOUNT)
        (asserts! (> token-allocation u0) ERR-INVALID-AMOUNT)
        (asserts! (not (var-get contract-paused)) ERR-PROJECT-INACTIVE)

        (map-set projects
            { project-id: project-id }
            {
                name: name,
                description: description,
                creator: tx-sender,
                funding-goal: funding-goal,
                current-funding: u0,
                token-allocation: token-allocation,
                active: true,
                created-at: block-height
            }
        )

        (var-set next-project-id (+ project-id u1))
        (var-set total-projects (+ (var-get total-projects) u1))
        (ok project-id)
    )
)

;; Invest in a bioengineering project
(define-public (invest-in-project (project-id uint) (amount uint))
    (let
        (
            (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
            (current-investment (default-to { amount: u0, tokens-received: u0 }
                (map-get? user-investments { user: tx-sender, project-id: project-id })))
            (tokens-to-receive (calculate-tokens amount (get token-allocation project) (get funding-goal project)))
        )
        (asserts! (get active project) ERR-PROJECT-INACTIVE)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (not (var-get contract-paused)) ERR-PROJECT-INACTIVE)

        ;; Transfer STX from investor to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;; Mint tokens to investor
        (try! (ft-mint? syn-bio-token tokens-to-receive tx-sender))

        ;; Update project funding
        (map-set projects
            { project-id: project-id }
            (merge project { current-funding: (+ (get current-funding project) amount) })
        )

        ;; Update user investment
        (map-set user-investments
            { user: tx-sender, project-id: project-id }
            {
                amount: (+ (get amount current-investment) amount),
                tokens-received: (+ (get tokens-received current-investment) tokens-to-receive)
            }
        )

        ;; Track investor for this project
        (map-set project-investors
            { project-id: project-id, investor: tx-sender }
            { investment-amount: amount }
        )

        (ok tokens-to-receive)
    )
)

;; Transfer syn-bio tokens between users
(define-public (transfer-tokens (amount uint) (recipient principal))
    (begin
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (try! (ft-transfer? syn-bio-token amount tx-sender recipient))
        (ok true)
    )
)

;; Burn tokens (for project completion or token redemption)
(define-public (burn-tokens (amount uint))
    (begin
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (try! (ft-burn? syn-bio-token amount tx-sender))
        (ok true)
    )
)

;; Admin function to pause/unpause contract
(define-public (set-contract-paused (paused bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (var-set contract-paused paused)
        (ok true)
    )
)

;; Admin function to deactivate a project
(define-public (deactivate-project (project-id uint))
    (let
        (
            (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (map-set projects
            { project-id: project-id }
            (merge project { active: false })
        )
        (ok true)
    )
)

;; read only functions

;; Get project details
(define-read-only (get-project (project-id uint))
    (map-get? projects { project-id: project-id })
)

;; Get user investment in a specific project
(define-read-only (get-user-investment (user principal) (project-id uint))
    (map-get? user-investments { user: user, project-id: project-id })
)

;; Get user token balance
(define-read-only (get-balance (user principal))
    (ft-get-balance syn-bio-token user)
)

;; Get total token supply
(define-read-only (get-total-supply)
    (ft-get-supply syn-bio-token)
)

;; Get total number of projects
(define-read-only (get-total-projects)
    (var-get total-projects)
)

;; Get next project ID
(define-read-only (get-next-project-id)
    (var-get next-project-id)
)

;; Check if contract is paused
(define-read-only (is-contract-paused)
    (var-get contract-paused)
)

;; Get contract owner
(define-read-only (get-contract-owner)
    CONTRACT-OWNER
)

;; Calculate funding progress percentage
(define-read-only (get-funding-progress (project-id uint))
    (match (map-get? projects { project-id: project-id })
        project (let
            (
                (current (get current-funding project))
                (goal (get funding-goal project))
            )
            (if (> goal u0)
                (some (/ (* current u100) goal))
                none
            )
        )
        none
    )
)

;; private functions

;; Calculate tokens to receive based on investment amount
(define-private (calculate-tokens (investment-amount uint) (token-allocation uint) (funding-goal uint))
    (if (> funding-goal u0)
        (/ (* investment-amount token-allocation) funding-goal)
        u0
    )
)

;; Check if user is project creator
(define-private (is-project-creator (user principal) (project-id uint))
    (match (map-get? projects { project-id: project-id })
        project (is-eq user (get creator project))
        false
    )
)

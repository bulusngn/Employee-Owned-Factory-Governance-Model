# 🏭 Employee-Owned Factory Governance Model

A decentralized autonomous organization (DAO) smart contract built on Stacks blockchain that enables employee ownership, productivity-based token distribution, and democratic governance for factory operations.

## 🌟 Features

### 👥 Employee Management
- Register and manage employee accounts
- Track employee productivity scores
- Active/inactive employee status management
- Automatic token distribution based on productivity

### 🪙 DAO Token System
- Fungible tokens representing ownership stakes
- Productivity-based token minting
- Token transfers between employees
- Balance and supply tracking

### 💰 Revenue Sharing
- Proportional revenue distribution based on token holdings
- Automated revenue pool management
- Employee revenue claim system
- Transparent revenue tracking

### 🗳️ Governance & Voting
- Democratic proposal creation system
- Token-weighted voting mechanism
- Proposal types: operational, financial, strategic
- Automatic proposal execution after voting period

## 📋 Contract Functions

### Read-Only Functions

**`get-employee`** - Retrieve employee information
```clarity
(get-employee principal)
```

**`get-balance`** - Check token balance for an account
```clarity
(get-balance principal)
```

**`get-total-supply`** - Get total token supply
```clarity
(get-total-supply)
```

**`get-revenue-pool`** - View current revenue pool amount
```clarity
(get-revenue-pool)
```

**`calculate-revenue-share`** - Calculate claimable revenue for an employee
```clarity
(calculate-revenue-share principal)
```

**`get-proposal`** - Get proposal details
```clarity
(get-proposal uint)
```

**`get-vote`** - Check if a user voted on a proposal
```clarity
(get-vote uint principal)
```

### Public Functions (Owner Only)

**`register-employee`** - Add a new employee to the system
```clarity
(register-employee principal)
```

**`deactivate-employee`** - Deactivate an employee account
```clarity
(deactivate-employee principal)
```

**`record-productivity`** - Record productivity score for an employee
```clarity
(record-productivity principal uint uint)
```

**`mint-tokens-for-productivity`** - Mint DAO tokens based on productivity
```clarity
(mint-tokens-for-productivity principal uint)
```

**`add-revenue`** - Add revenue to the distribution pool
```clarity
(add-revenue uint)
```

**`update-min-proposal-tokens`** - Update minimum tokens required for proposals
```clarity
(update-min-proposal-tokens uint)
```

### Public Functions (Employee)

**`claim-revenue-share`** - Claim proportional revenue share
```clarity
(claim-revenue-share)
```

**`create-proposal`** - Create a governance proposal
```clarity
(create-proposal (string-ascii 100) (string-ascii 500) uint (string-ascii 50))
```

**`vote-on-proposal`** - Vote on an active proposal
```clarity
(vote-on-proposal uint bool)
```

**`execute-proposal`** - Execute a passed proposal after voting period
```clarity
(execute-proposal uint)
```

**`transfer-tokens`** - Transfer tokens between accounts
```clarity
(transfer-tokens uint principal principal)
```

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for deployment

### Installation

1. Clone the repository
```bash
git clone https://github.com/bulusngn/Employee-Owned-Factory-Governance-Model.git
cd Employee-Owned-Factory-Governance-Model
```

2. Check contract syntax
```bash
clarinet check
```

3. Run tests
```bash
clarinet test
```

### Deployment

1. Deploy to testnet
```bash
clarinet deploy --testnet
```

2. Deploy to mainnet
```bash
clarinet deploy --mainnet
```

## 💡 Usage Examples

### Example 1: Register Employee and Mint Tokens
```clarity
;; Register new employee
(contract-call? .Employee-Owned-Factory-Governance-Model register-employee 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Record productivity
(contract-call? .Employee-Owned-Factory-Governance-Model record-productivity 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u100 u1)

;; Mint tokens based on productivity
(contract-call? .Employee-Owned-Factory-Governance-Model mint-tokens-for-productivity 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u500)
```

### Example 2: Create and Vote on Proposal
```clarity
;; Create proposal
(contract-call? .Employee-Owned-Factory-Governance-Model create-proposal "Expand Production" "Proposal to add new production line" u144 "operational")

;; Vote on proposal
(contract-call? .Employee-Owned-Factory-Governance-Model vote-on-proposal u1 true)

;; Execute after voting period
(contract-call? .Employee-Owned-Factory-Governance-Model execute-proposal u1)
```

### Example 3: Revenue Distribution
```clarity
;; Owner adds revenue
(contract-call? .Employee-Owned-Factory-Governance-Model add-revenue u10000)

;; Employee claims their share
(contract-call? .Employee-Owned-Factory-Governance-Model claim-revenue-share)
```

## 🔒 Security Features

- Owner-only functions for employee management
- Employee verification for voting and revenue claims
- Duplicate vote prevention
- Token balance requirements for proposals
- Active employee status checks

## 📊 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only |
| u101 | Not an employee |
| u102 | Already an employee |
| u103 | Invalid amount |
| u104 | Insufficient balance |
| u105 | Proposal not found |
| u106 | Already voted |
| u107 | Proposal expired |
| u108 | Proposal not ended |
| u109 | Proposal failed |
| u110 | No revenue available |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Links

- [Stacks Blockchain](https://www.stacks.co/)
- [Clarity Language](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)

---

Built with ❤️ for decentralized worker ownership

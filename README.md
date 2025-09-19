# SyntheticBiology Smart Contract

SyntheticBiology is a Clarity smart contract on the Stacks blockchain that manages synthetic biological assets and enables investment in bioengineering projects. The contract provides exposure to synthetic organism development through tokenized investments and project funding mechanisms.

## Overview

This smart contract creates a decentralized platform for funding and managing bioengineering projects. Investors can contribute STX tokens to projects and receive syn-bio tokens in return, representing their stake in synthetic biology research and development.

## Features

- **Project Creation**: Create bioengineering projects with funding goals and token allocations
- **Investment System**: Invest STX in projects and receive proportional syn-bio tokens
- **Token Management**: Mint, transfer, and burn syn-bio fungible tokens
- **Project Tracking**: Monitor funding progress and project status
- **Access Control**: Admin functions for contract management and project oversight
- **Investment History**: Track user investments across multiple projects

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Clarity Version**: 2
- **Epoch**: 2.5
- **Token Standard**: SIP-010 Fungible Token

### Contract Components

#### Fungible Token
- `syn-bio-token`: The primary token representing synthetic biology investment shares

#### Data Structures
- **Projects**: Store project metadata, funding status, and token allocations
- **User Investments**: Track individual user investments per project
- **Project Investors**: Map investors to their project investments

#### Error Codes
- `u100`: Owner-only operation
- `u101`: Not token owner
- `u102`: Insufficient balance
- `u103`: Project not found
- `u104`: Project already exists
- `u105`: Invalid amount
- `u106`: Project inactive

## Installation

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) CLI tool
- Node.js and npm for testing
- Stacks wallet for deployment

### Setup
1. Clone the repository:
```bash
git clone <repository-url>
cd SyntheticBiology
```

2. Install dependencies:
```bash
cd SyntheticBiology_contract
npm install
```

3. Run tests:
```bash
npm test
```

4. Generate test coverage:
```bash
npm run test:report
```

## Usage Examples

### Initialize Contract
```clarity
;; Initialize with 1,000,000 initial tokens
(contract-call? .SyntheticBiology initialize u1000000)
```

### Create a Bioengineering Project
```clarity
(contract-call? .SyntheticBiology create-project
    "Gene Therapy Research"
    "Development of CRISPR-based gene therapy for rare diseases"
    u500000  ;; funding goal: 500,000 microSTX
    u100000  ;; token allocation: 100,000 tokens
)
```

### Invest in a Project
```clarity
;; Invest 10,000 microSTX in project ID 1
(contract-call? .SyntheticBiology invest-in-project u1 u10000)
```

### Transfer Tokens
```clarity
;; Transfer 1,000 syn-bio tokens to another address
(contract-call? .SyntheticBiology transfer-tokens u1000 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Check Project Status
```clarity
;; Get project details
(contract-call? .SyntheticBiology get-project u1)

;; Check funding progress
(contract-call? .SyntheticBiology get-funding-progress u1)
```

## Contract Functions

### Public Functions

#### `initialize (initial-supply uint)`
Initializes the contract and mints initial tokens to the contract owner.
- **Access**: Owner only
- **Parameters**: `initial-supply` - Number of tokens to mint initially
- **Returns**: `(ok true)` on success

#### `create-project (name string-ascii-50) (description string-ascii-200) (funding-goal uint) (token-allocation uint)`
Creates a new bioengineering project for funding.
- **Parameters**:
  - `name` - Project name (max 50 characters)
  - `description` - Project description (max 200 characters)
  - `funding-goal` - Target funding amount in microSTX
  - `token-allocation` - Number of tokens allocated to this project
- **Returns**: Project ID on success

#### `invest-in-project (project-id uint) (amount uint)`
Invest STX in a project and receive proportional syn-bio tokens.
- **Parameters**:
  - `project-id` - ID of the project to invest in
  - `amount` - Investment amount in microSTX
- **Returns**: Number of tokens received

#### `transfer-tokens (amount uint) (recipient principal)`
Transfer syn-bio tokens between users.
- **Parameters**:
  - `amount` - Number of tokens to transfer
  - `recipient` - Address to receive tokens
- **Returns**: `(ok true)` on success

#### `burn-tokens (amount uint)`
Burn tokens from caller's balance.
- **Parameters**: `amount` - Number of tokens to burn
- **Returns**: `(ok true)` on success

#### `set-contract-paused (paused bool)`
Pause or unpause contract operations.
- **Access**: Owner only
- **Parameters**: `paused` - True to pause, false to unpause
- **Returns**: `(ok true)` on success

#### `deactivate-project (project-id uint)`
Deactivate a project to prevent further investments.
- **Access**: Owner only
- **Parameters**: `project-id` - ID of project to deactivate
- **Returns**: `(ok true)` on success

### Read-Only Functions

#### `get-project (project-id uint)`
Retrieve project details including funding status and metadata.

#### `get-user-investment (user principal) (project-id uint)`
Get user's investment details for a specific project.

#### `get-balance (user principal)`
Get user's syn-bio token balance.

#### `get-total-supply()`
Get total supply of syn-bio tokens.

#### `get-total-projects()`
Get total number of projects created.

#### `get-funding-progress (project-id uint)`
Calculate funding progress as a percentage.

#### `is-contract-paused()`
Check if contract operations are paused.

#### `get-contract-owner()`
Get the contract owner's address.

## Deployment Guide

### Local Development (Devnet)
```bash
clarinet integrate
```

### Testnet Deployment
1. Configure testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
1. Update `settings/Mainnet.toml` with production parameters
2. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## Security Notes

### Access Control
- Contract owner has exclusive access to initialization, pausing, and project deactivation
- Users can only transfer their own tokens
- Investments are automatically processed without manual approval

### Token Economics
- Tokens are minted proportionally to investment amounts
- Token allocation per project is fixed at creation
- Burning tokens is irreversible

### Investment Safety
- Projects can be deactivated by the owner to prevent further investments
- Contract can be paused in emergency situations
- All investments are recorded and traceable

### Audit Considerations
- Ensure proper access control implementation
- Validate all mathematical operations for overflow protection
- Test token minting and burning mechanisms thoroughly
- Verify investment calculation accuracy

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Ensure all tests pass
5. Submit a pull request

## Testing

Run the test suite to ensure contract functionality:

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

## License

This project is licensed under the ISC License.

## Support

For questions, issues, or contributions, please open an issue in the repository or contact the development team.
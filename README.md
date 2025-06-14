# Tokenized Non-Profit Impact Measurement System

A comprehensive blockchain-based system for measuring, tracking, and verifying non-profit impact using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a transparent, immutable, and tokenized approach to non-profit impact measurement, enabling donors to track their contributions and see real-time impact metrics while ensuring accountability and verification of non-profit organizations.

## System Architecture

### Core Contracts

1. **Non-Profit Verification Contract** (`nonprofit-verification.clar`)
    - Validates and registers non-profit organizations
    - Manages verification status and credentials
    - Handles organization metadata and compliance

2. **Program Tracking Contract** (`program-tracking.clar`)
    - Tracks individual non-profit programs
    - Manages program lifecycle and milestones
    - Records program metadata and objectives

3. **Impact Measurement Contract** (`impact-measurement.clar`)
    - Measures and records program impact metrics
    - Calculates impact scores and ratings
    - Provides standardized impact assessment

4. **Donor Reporting Contract** (`donor-reporting.clar`)
    - Generates impact reports for donors
    - Tracks donation allocation and outcomes
    - Provides transparency in fund utilization

5. **Improvement Coordination Contract** (`improvement-coordination.clar`)
    - Coordinates program improvements based on impact data
    - Facilitates feedback loops and optimization
    - Manages improvement recommendations and implementations

## Features

### For Non-Profits
- **Verification System**: Streamlined verification process with blockchain-based credentials
- **Program Management**: Comprehensive program tracking and milestone management
- **Impact Measurement**: Standardized metrics and automated impact calculation
- **Transparency**: Real-time reporting and data visibility
- **Improvement Tools**: Data-driven improvement recommendations

### For Donors
- **Verified Organizations**: Donate only to verified non-profits
- **Impact Tracking**: Real-time visibility into program impact
- **Donation Tracking**: Track how donations are allocated and used
- **Impact Reports**: Detailed reports on donation outcomes
- **Performance Metrics**: Standardized impact scores and ratings

### For the Ecosystem
- **Transparency**: All data stored immutably on blockchain
- **Standardization**: Common metrics and measurement standards
- **Accountability**: Automated verification and reporting
- **Efficiency**: Reduced overhead through automation
- **Trust**: Cryptographic proof of impact and fund usage

## Smart Contract Functions

### Non-Profit Verification
- `register-nonprofit`: Register a new non-profit organization
- `verify-nonprofit`: Verify a non-profit's credentials
- `update-verification-status`: Update verification status
- `get-nonprofit-info`: Retrieve non-profit information

### Program Tracking
- `create-program`: Create a new program
- `update-program-status`: Update program status
- `add-milestone`: Add program milestone
- `get-program-details`: Retrieve program information

### Impact Measurement
- `record-impact`: Record impact metrics
- `calculate-impact-score`: Calculate standardized impact score
- `get-impact-data`: Retrieve impact measurements
- `generate-impact-summary`: Generate impact summary

### Donor Reporting
- `create-donation-record`: Record donation
- `generate-donor-report`: Generate impact report for donor
- `track-donation-usage`: Track how donations are used
- `get-donor-impact`: Get donor's total impact

### Improvement Coordination
- `submit-improvement-plan`: Submit program improvement plan
- `approve-improvement`: Approve improvement implementation
- `track-improvement-progress`: Track improvement progress
- `get-improvement-recommendations`: Get AI-generated recommendations

## Data Models

### Non-Profit Organization
```clarity
{
  id: uint,
  name: (string-ascii 100),
  registration-number: (string-ascii 50),
  verification-status: (string-ascii 20),
  verification-date: uint,
  contact-info: (string-ascii 200),
  mission-statement: (string-ascii 500),
  focus-areas: (list 10 (string-ascii 50)),
  verified-by: principal
}
```

### Program
```clarity
{
  id: uint,
  nonprofit-id: uint,
  name: (string-ascii 100),
  description: (string-ascii 500),
  start-date: uint,
  end-date: uint,
  status: (string-ascii 20),
  budget: uint,
  target-beneficiaries: uint,
  actual-beneficiaries: uint,
  milestones: (list 20 uint)
}
```

### Impact Metrics
```clarity
{
  program-id: uint,
  metric-type: (string-ascii 50),
  baseline-value: uint,
  current-value: uint,
  target-value: uint,
  measurement-date: uint,
  verified: bool,
  impact-score: uint
}
```

## Usage Examples

### Registering a Non-Profit
```clarity
(contract-call? .nonprofit-verification register-nonprofit
  "Education for All Foundation"
  "REG12345"
  "Building educational opportunities for underprivileged children"
  (list "education" "children" "literacy")
  "contact@educationforall.org")
```

### Creating a Program
```clarity
(contract-call? .program-tracking create-program
  u1 ;; nonprofit-id
  "Literacy Program 2024"
  "Teaching basic literacy skills to 500 children in rural areas"
  u1672531200 ;; start-date
  u1703980800 ;; end-date
  u50000 ;; budget
  u500) ;; target-beneficiaries
```

### Recording Impact
```clarity
(contract-call? .impact-measurement record-impact
  u1 ;; program-id
  "literacy-rate"
  u20 ;; baseline: 20% literacy rate
  u65 ;; current: 65% literacy rate
  u80 ;; target: 80% literacy rate
  u1688169600) ;; measurement-date
```

## Testing

The system includes comprehensive tests using Vitest:

```bash
# Run all tests
npm test

# Run specific test file
npm test nonprofit-verification.test.js

# Run tests in watch mode
npm test -- --watch
```

## Security Considerations

- **Access Control**: Role-based access control for sensitive functions
- **Data Validation**: Input validation and sanitization
- **Verification**: Multi-step verification process for non-profits
- **Immutability**: Critical data stored immutably on blockchain
- **Transparency**: All operations are publicly auditable

## Integration

### API Integration
The contracts can be integrated with web applications using the Stacks.js library:

```javascript
import { ContractCallTransaction } from '@stacks/transactions';

// Example: Register non-profit
const registerNonprofit = async (name, regNumber, mission) => {
  const txOptions = {
    contractAddress: 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE',
    contractName: 'nonprofit-verification',
    functionName: 'register-nonprofit',
    functionArgs: [/* ... */],
    // ... other options
  };
  
  return await makeContractCall(txOptions);
};
```

### Frontend Integration
Build user interfaces that interact with the smart contracts to provide:
- Non-profit registration portals
- Donor dashboards
- Impact visualization tools
- Program management interfaces

## Deployment

1. Deploy contracts to Stacks blockchain
2. Configure contract interactions
3. Set up monitoring and alerts
4. Initialize system with verified validators

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For questions and support, please open an issue in the repository or contact the development team.

## Roadmap

- [ ] Advanced analytics and AI-powered insights
- [ ] Mobile application development
- [ ] Integration with existing non-profit management systems
- [ ] Multi-chain support
- [ ] Advanced tokenization features
- [ ] Governance token implementation

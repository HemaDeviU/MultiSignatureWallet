# Multi-Signature Wallet Smart Contract

Solidity smart contract for a multi-signature wallet to be implemented on the Ethereum blockchain. The contract allows multiple owners to collectively manage funds stored in the wallet, requiring a configurable number of confirmations from the owners to execute transactions.

## Features

- Multi-signature functionality: Multiple owners can control the wallet.
- Configurable confirmations: Number of confirmations required to execute a transaction is customizable.
- Secure transactions: Transactions require confirmation from multiple owners to be executed.
- Event logging: Events are emitted for deposit, transaction submission, confirmation, execution, and confirmation revocation.

## Usage

1. After auditing, Deploy the smart contract to the Ethereum blockchain.
2. Configure the initial set of owners and the required number of confirmations during contract deployment.
3. Owners can submit transactions using the `submitTransaction` function.
4. Other owners can confirm the transactions using the `confirmTransaction` function.
5. Once the required number of confirmations is reached, an owner can execute the transaction using the `executeTransaction` function.
6. Owners can also revoke their confirmation on a pending transaction using the `revokeConfirmation` function.
7. Check the balance of the wallet using the `getBalance` function.

## Installation

Clone this repository:

```bash
git clone https://github.com/HemaDeviU/multi-signature-wallet.git
```

### Test

```shell
$ forge test
```

### Gas Snapshots

```shell
$ forge snapshot
```

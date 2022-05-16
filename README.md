# LimeAcademy

## Lesson - Intro to Blockchain

- What is a transaction? Any change to the ledger can be described as a transaction. Transactions must adhere to strict rules checked by the nodes.
- What is the approximate time of every Ethereum transaction? It depends on the offered gas fees. The nodes first include transactions with higher gas fees when mining blocks. In theory, Ethereum network can process around 15 transactions per second. Depending on volume, any transaction gets verified in between 15 seconds and 5 minutes.
- What is a node? Computer running a specific software which synchronizes its version of the ledger with all other nodes.

## Lesson - Learning Solidity

### What is delegatecall? Give example with code.

Delegatecall executes the code at the target address in the context of the calling contract. Storage, address and balance refer to the calling contract, only the code is taken from the called address.

### What is multicall? Give example with code.

Aggregates multiple queries in one call.

### What is time lock? Give example with code.

Timelock delays an execution of a function so that it gives the user some time to react after the transaction is submitted.

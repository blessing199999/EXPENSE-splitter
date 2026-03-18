# EXPENSE-splitter

A Clarity smart contract for splitting shared expenses among a group of participants on the Stacks blockchain.

## Overview
This contract allows a group of people to split a shared expense (e.g., a dinner bill). One person pays the bill, and the contract records how much each participant owes. The contract tracks payments until the expense is fully settled.

## Features
- Register participants
- Set and store the total expense
- Calculate equal share per participant
- Allow participants to pay their share
- Track payment completion
- Query contract state (total expense, share per person, participant count, payment status)

## How It Works
1. **Owner Deployment:**
   - The contract deployer becomes the owner (typically the person who paid the bill).
2. **Add Participants:**
   - The owner registers each participant using their principal address.
3. **Set Expense:**
   - The owner sets the total expense amount. The contract calculates the equal share for each participant.
4. **Pay Share:**
   - Each participant pays their share to the owner via the contract.
5. **Track Payments:**
   - The contract tracks who has paid and who still owes their share.

## Contract Functions

### Public Functions
- `add-participant (member principal)` — Owner adds a participant.
- `set-expense (amount uint)` — Owner sets the total expense amount.
- `pay-share` — Participant pays their share.

### Read-Only Functions
- `get-total-expense` — Returns the total expense amount.
- `get-share-per-person` — Returns the share each participant must pay.
- `get-participant-count` — Returns the number of participants.
- `has-paid (member principal)` — Checks if a participant has paid.

## Error Codes
- `u100` — Unauthorized (only owner can perform this action)
- `u101` — Not a registered participant
- `u102` — Already paid
- `u103` — Invalid amount or operation

## Example Usage
1. Deploy the contract (owner is set automatically).
2. Owner calls `add-participant` for each participant.
3. Owner calls `set-expense` with the total amount.
4. Each participant calls `pay-share` to settle their part.
5. Use read-only functions to check payment status and contract state.

## File Structure
- `contracts/EXPENSE-splitter.clar` — Clarity smart contract
- `tests/EXPENSE-splitter.test.ts` — Contract tests


# Assign Votes

Since the attack was expected to happen in just one transaction, this was supposed to be done from a smart contract.

## How to complete

On deployment of the solution contract by the attacker, following things take place:

1. constructor calls and forwards its parameters (the address of AssignVotes contract and a bytes data - which can be `0x`) to the internal `solve(address,bytes)` function
2. Inside `solve(address,bytes)`, a proposal is first created (and it's ID is stored in a var) which has the address of the attacker (msg.sender) as the `target` and 1 ether as the `value` (the `data` could be `0x`)
3. Now to execute this proposal (and send ourselves 1 ether), we also need to give it 10 votes from different addresses
4. But the catch is that an address (say A) has to first assign (by calling `assign(address)` on the `AssignVotes` contract) an address (say B) before it (B) could vote for a proposal
5. And also, an address can assign only 6 addresses as a voter
6. So, after the proposal creation, 10 voter contracts will be deployed and the first 6 (indexes 0-5) of them would be assigned by the solution contract
7. From the 5th voter contract onwards, each contract will also assign the next contract. That is: VC5-VC6, VC6-VC7, VC7-VC8, VC8-VC9
8. Right after assignments, the voter contract will give votes to the proposal
9. After doing this, check the amount of votes for the proposal that was created in the 2nd step. It should be 10
10. After confirming that, just call `execute(uint)`

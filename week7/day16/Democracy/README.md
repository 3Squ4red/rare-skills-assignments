# Democracy

You don't even have to write any contract for this one 😎

## How to complete

1. The attacker nominates himself as a challenger
    - Now he gets two NFTs (of ids 0 and 1)
    - And also, because the election is rigged, the attacker gets 3 votes and the incumbent gets 5 votes
2. The attacker gives one of his NFTs to his other address
   - This is necessary for the next step
3. The attacker's other account gives a vote to the attacker
   - Now, the attacker has 4 votes, because on voting for a candidate, the no. of NFTs held by the voter gets added to the votes of that candidate
4. The attacker's other account sends back the NFT (of id 0)
   - Now the attacker has 2 NFTs on his main account
5. Now the attacker gives a vote to himself
   - On doing this, the attacker will have 6 votes
   - And also, he will become the owner of the contract
6. Finally, the attacker will now withdraw the funds from the contract (by calling `withdrawToAddress(address)`)

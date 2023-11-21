# Side Entrance

## How to complete

Write a contract that first takes a flash loan of 1000 ether. This would bring the execution back to your contract - to the `execute()` function in which deposit (calling `deposit()`) 1000 ether back into the pool. Now this contract's balance has been recorded in the `balances` mapping of the pool as 1000 ether (in wei), so your contract can now simply call `withdraw()` and take back 1000 ethers from the pool.

Be sure to add the `receive()` function in this contract and send the funds to your address from it.

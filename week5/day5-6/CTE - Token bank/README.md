# Token sale

This exercise's contract code was comparatively larger than the previous ones. Nevertheless, after spending some time reading through them, I realized that to drain the bank of all tokens, I just need to invoke a reentrancy attack by simply calling the `withdraw(uint265)` function from another contract that has implemented the `tokenFallback(address,uint256)` function in such a way that it keeps withdrawing until the bank is drained (and the challenge is solved).

## How to complete

Create another contract and write a function which takes the address of the bank as its parameter and calls the `withdraw(uint265)` with `500000 * 10 ** 18` as its parameter on it.

*NOTE* Do not take in the bank's address from the constructor as this would make it impossible to deploy the contract *because* the bank's constructor asks for the address of the player (which will be our contract), so it couldn't be deployed without deploying our contract first.

Now, set the bank's address in a state variable. This would help withdraw tokens from the `tokenFallback(address,uint256)` function.

Also, write a `tokenFallback(address,uint256)` function in which withdraw `500000 * 10 ** 18` tokens if the challenge is not yet completed (`isComplete()` of bank returns true).

Now deploy this contract first and then the bank, passing in the solution contract's address as its parameter. After this, just call in the function which initiates the reentrancy attack (by simply withdrawing tokens).

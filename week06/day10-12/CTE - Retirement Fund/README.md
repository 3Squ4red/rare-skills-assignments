# Retirement Fund

Arithmetic underflow is going to help us in solving this one.

## How to complete

Forcefully send 1 wei to the contract (using `selfdestruct`) and then call `collectPenalty()`.
On doing this, underflow will occur on line 34:

`uint256 withdrawn = startBalance - address(this).balance;`

As the current balance of the contract is greater than its starting balance. Therefore, the *beneficiary* will now get all of the contract's balance.

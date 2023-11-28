# Telephone

You have to know the difference between `tx.origin` and `msg.sender` for this one.

## How to complete

Just call `changeOwner(address)` passing in your address, from another contract.
This will work because `tx.origin` will be your wallet address and `msg.sender` will be the address of the contract. So, the `require` statement will pass, setting you as the owner.

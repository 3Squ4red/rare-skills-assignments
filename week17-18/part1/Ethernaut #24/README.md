# Puzzle Wallet
The solution to this involves two major things:
1. Gaining control over `PuzzleWallet` by becoming its owner.
2. Draining the wallet (actually proxy) of all it's ether so that we can call `setMaxBalance` and update slot 1, where `admin` is stored.

# How to complete

S1 - Call `proposeNewAdmin` passing in your address

This will update `pendingAdmin` (stored at slot 0) with your address AND also the `owner` of `PuzzleWallet` as it is also reading from the same slot 0.

S2 - Call `addToWhitelist` passing in your address

Time to whitelist yourself!

S3 - Call `multicall` passing in an array of size 2: the `deposit` function selector, the `multicall` function selector with an array of size 1: the `deposit` function selector. Also, pass along 0.001 ether    

`admin` is stored at slot 1 in the **PuzzleProxy** contract. In order to update it, we somehow have to call `setMaxBalance` function because `maxBalance` in **PuzzleWallet** also uses slot 1 of the **PuzzleProxy** contract.

Doing this step would cause the `msg.value` to be recorded two times allowing us to withdraw more than we deposited.

S4 - Call `execute` passing in your address, 0.2, and `0x`

This would drain all funds from the contract.

S5 - Call `setMaxBalance`

Now simply call `setMaxBalance` passing in the decimal value of your address.

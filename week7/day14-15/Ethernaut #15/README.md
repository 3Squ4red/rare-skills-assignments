# Naught Coin

## How to complete

The 10 years time lock (the `lockTokens` modifier) has been put on the `transfer(address,uint)` function only. There's another function present in the ERC20 standard which can move the tokens around. The `transferFrom(address,address,uint)` function.

But before using this function to move the tokens out of your account, you first have to give allowance to your own address for spending all the tokens from your account. So, call `approve(address,uint)` first.

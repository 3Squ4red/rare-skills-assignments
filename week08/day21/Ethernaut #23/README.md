# Ethernaut - DexTwo

There was no restriction to the `from` and `to` tokens to be swapped in the `swap` function. This allows us to swap any two ERC20 tokens, not just the ones set by the owner using the `setTokens(address,address)` function.

Therefore, in order to take out all token1 from the pool, we can create another ERC20 token and swap it for 100 token1.

The formula used to calculate the token out (y) is the following:

```
y = (x*a)/b

Where:
x = amount of `from` tokens given by the swapper
a = amount of `to` tokens in the pool
b = amount of `from` tokens in the pool
```

The pool has a balance of 100 token1 i.e. `a = 100`. And we want `y` to be 100. So, the value of `x` and `b` should be the **same**. That is, the number of tokens we should put in the pool (to get 100 tokens out of it) should be equal to the number of that token present in the pool.

To achieve this, mint 1 uint of an ERC20 token to the pool and to yourself. Then swap it. for token1 from the pool. You'll get 100 of it!

Do the same thing to take out 100 token2 from the pool

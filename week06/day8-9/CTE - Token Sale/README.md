# Token Sale

The catch here is tricking the `require(msg.value == numTokens * PRICE_PER_TOKEN);` statement on line 16 by forcing overflow by supplying a very large number as `numTokens`.

If the number is not large enough to cause overflow, we will have to send the same number of ether as well, which will cost us a lot.
So, to figure out enough no. of tokens to buy and the amount of wei needed to buy them, we're going to use following formulas:

- `numTokens = MAX_UNIT_256 / PRICE_PER_TOKEN + 1`
- `msg.value = numTokens - MAX_UNIT_256`

## How to complete

Use the above formulas to calculate the no. of tokens to buy and the amount of wei to send:

`numTokens` = 2^256 / 10^18 + 1 = 115792089237316195423570985008687907853269984665640564039458
`msg.value` = (2^256 / 10^18 + 1) * 10^18 - 2^256 = 415992086870360064 ~= 0.41 ETH

Now call `buy(uint)` passing `115792089237316195423570985008687907853269984665640564039458` to it's parameter and send along `415992086870360064` wei.

Multiplication of `115792089237316195423570985008687907853269984665640564039458` by `1 ether (10^18)` will produce a product of `415992086870360064` which is the exact amount of wei we're sending in this transaction. Therefore, the `require` statement will pass.

After this, the contract will have approximately 1.41 ETH. So, to bring the contract's balance down to less than 1 ether, we can now simply sell off 1 token by calling `sell(`uint)` and passing 1 to its parameter.

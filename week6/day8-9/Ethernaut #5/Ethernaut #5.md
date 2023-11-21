# Token

Prior to Soliidty 0.8.0, 0-1 equals 115792089237316195423570985008687907853269984665640564039457584007913129639935!!!
Which means that `uint`s overflowed and underflowed all the time.

## How to complete

There's no need to write any contract. Just send 21 tokens to any valid address (I sent it back to the contract address).
This will cause underflow on lines 14 - which will satisfy the require condition, and 15 - which will set a very huge amount 
as our balance.

# Reentrance

A classic example of reentrancy attack. This attack happens on a contract which holds contributions from different people and one of them withdraws not only his share but also a part of/all of others as well.
This happens due to updating the balance of a withdrawer **after** returning them their share.

Note that if a contract sends all of its balance at once, there would be no point in performing a reentrancy attack.

## How to complete

Write a contract which donates a small amount (preferrably 0.001 ether cause this is the amount it starts with) to the reentrance contract and then withdraw it back. Add a `receive()` function in which call back the `withdraw(uint)` function again passing in `msg.value` as parameter.

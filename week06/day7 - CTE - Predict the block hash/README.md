# Predict the block hash

In this exercise, we have to guess the hash of a future block (the next block after the one in which we sent our lock-in tx). There is no way to *actually* predict the hash of a block that has not been mined yet.


But there's help in the Solidity docs!

> The block hashes are not available for all blocks for scalability reasons. You can only access the hashes of the most recent 256 blocks, all other values will be zero.


This means that looking at the hash of the last 257th block (and further behind) will return '0x0000000000000000000000000000000000000000000000000000000000000000'.


So, to make a successful guess, we can lock in '0x0000000000000000000000000000000000000000000000000000000000000000' and then wait for 257 blocks to be mined before calling `settle()`.

*NOTE* You can manually mine extra blocks in a hardhat test like this:

```JS
    const initBlockNumber = await ethers.provider.getBlockNumber();
    let lastBlockNumber = initBlockNumber;
    do {
      lastBlockNumber = await ethers.provider.getBlockNumber();
      await ethers.provider.send("evm_mine", []);
    } while (lastBlockNumber - initBlockNumber < 256);
```

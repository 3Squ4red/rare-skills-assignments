// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import './BondToken.sol';

contract TestBondToken {
    BondToken bondToken;

    event Log(uint);

    constructor() payable {
        bondToken = new BondTkoen();

        emit Log(msg.value);
        assert(bondToken.name() == "BondToken");
    }
}

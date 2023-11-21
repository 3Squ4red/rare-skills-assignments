//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Token.sol";

contract TestToken is Token {
    address echidna_caller = msg.sender;

    constructor() {
        balances[echidna_caller] = 10000;
        paused(); // pause the contract
        owner = address(0); // lose ownership
    }

    // add the property
    function echidna_test_balance() public view returns (bool) {
        return balances[echidna_caller] <= 10000;
    }

    function echidna_no_transfer() public view returns (bool) {
        return is_paused;
    }

    function testPausable() public view {
        assert(is_paused);
    }
}

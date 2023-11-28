//SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

import "./TokenWhaleChallenge.sol";

/**
Attacker address: a
Proxy address (attacker has control over this): b
Random address (this could also be the token contract address itself): c
type(uint256).max: MAX

a has 1000 SET

Attack sequence:
a approves b for 1 SET
b transfers 1 SET from a to c
    this causes underflow on line 27
    `balanceOf[msg.sender] -= value;`
    msg.sender is b and b has balance 0
    so, 0-1=MAX
    therefore b gets MAX balance
b transfers `MAX - 1000` SET to a
    a now has MAX SET as he already had a balance of 1000
*/

contract TestWhale is TokenWhaleChallenge {
    address echidna_caller = msg.sender;

    constructor() public TokenWhaleChallenge(echidna_caller) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }
}

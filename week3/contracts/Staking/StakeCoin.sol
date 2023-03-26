// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @dev StakeGame will be the owner of this coin
contract StakeCoin is ERC20, Ownable {
    constructor() ERC20("Stake Coin", "STKC") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

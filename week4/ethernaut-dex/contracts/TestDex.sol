// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Dex.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestDex {
    address instanceAddress;

    constructor() {
        Dex instance = new Dex();
        instanceAddress = address(instance);

        SwappableToken tokenInstance = new SwappableToken(
            instanceAddress,
            "Token 1",
            "TKN1",
            110
        );
        SwappableToken tokenInstanceTwo = new SwappableToken(
            instanceAddress,
            "Token 2",
            "TKN2",
            110
        );

        address tokenInstanceAddress = address(tokenInstance);
        address tokenInstanceTwoAddress = address(tokenInstanceTwo);

        instance.setTokens(tokenInstanceAddress, tokenInstanceTwoAddress);

        tokenInstance.approve(instanceAddress, 100);
        tokenInstanceTwo.approve(instanceAddress, 100);

        instance.addLiquidity(tokenInstanceAddress, 100);
        instance.addLiquidity(tokenInstanceTwoAddress, 100);

        tokenInstance.transfer(msg.sender, 10);
        tokenInstanceTwo.transfer(msg.sender, 10);

        // (bool success, bytes memory data) = instanceAddress.delegatecall(
        //     abi.encodeWithSignature("approve(address,uint256)", instanceAddress, type(uint128).max)
        // );
        tokenInstance.approve(msg.sender, instanceAddress, type(uint128).max);
    }

    /*
    owner is not me
    testSetup() for testing if the test was set up correctly
    */

    function testDex() public view returns (bool) {
        //
        address token1 = Dex(instanceAddress).token1();
        address token2 = Dex(instanceAddress).token2();
        assert(
            IERC20(token1).balanceOf(instanceAddress) != 0 ||
                ERC20(token2).balanceOf(instanceAddress) != 0
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    function calculateAddress(address deployer)
        external
        pure
        returns (address contractAddress)
    {
        contractAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            deployer,
                            bytes1(0x01)
                        )
                    )
                )
            )
        );
    }
}

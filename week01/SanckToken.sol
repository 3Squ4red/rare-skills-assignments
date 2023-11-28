// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "https://github.com/vittominacori/erc1363-payable-token/blob/master/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanckToken is ERC1363, IERC1363Receiver, Ownable {
    mapping(address => bool) public isSanctioned;

    /// @notice Sets the token name and symbol
    /// @dev Makes msg.sender the owner of this token
    constructor() ERC20("Sanck Token", "SANC") {}

    /// @notice Lets the owner sanction an address
    /// @dev Will revert if anyone except the owner calls
    /// @dev Will not override the mapping if _addr is already sanctioned
    /// @param _addr The address which is going to be sanctioned from sending or receving SANC
    function addSanction(address _addr) external onlyOwner {
        require(_addr != address(0), "SANC: 0 address");

        if (!isSanctioned[_addr]) isSanctioned[_addr] = true;
    }

    /// @notice Lets the owner remove sanction from an address
    /// @dev Will revert if anyone except the owner calls
    /// @dev Will not override the mapping if _addr is not sanctioned
    /// @param _addr The address which will be removed from sanction
    function removeSanction(address _addr) external onlyOwner {
        require(_addr != address(0), "SANC: 0 address");

        if (isSanctioned[_addr]) isSanctioned[_addr] = false;
    }

    /// @dev See {ERC20-_mint}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @dev See {ERC20-_beforeTokenTransfer}
    /// @notice Reverts if `from` or `to` is sanctioned
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(
            !isSanctioned[from] && !isSanctioned[to],
            "SANC: Sanctioned Transfer"
        );
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @dev See {IERC1363Receiver-onTransferReceived}
    /// @notice rejects any tokens sent
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4) {
        revert("SANC: cannot receive tokens");
    }
}

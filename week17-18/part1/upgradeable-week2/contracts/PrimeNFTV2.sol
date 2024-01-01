// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PrimeNFTV2 is Initializable, ERC721EnumerableUpgradeable, OwnableUpgradeable {
    // This will always hold the next available token id
    uint256 private tokenId;

    uint public constant MAX_SUPPLY = 20;

     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initializeV2(address initialOwner) public reinitializer(2) {
        __Ownable_init(initialOwner);
    }

    /// @notice Creates an NFT to msg.sender
    /// @dev Will revert if 20 NFTs (tokenIds 1-20) have already been minted
    function mint() external {
        require(tokenId <= MAX_SUPPLY, "PrimeNFT: cap reached");

        _mint(msg.sender, tokenId);
        tokenId++;
    }

    /// @notice Allows the owner to transfer NFTs between any addresses
    function godTransfer(address to, uint _tokenId) external onlyOwner {
        _update(to, _tokenId, address(0));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PrimeNFT is Initializable, ERC721EnumerableUpgradeable {
    // This will always hold the next available token id
    uint256 private tokenId;

    uint public constant MAX_SUPPLY = 20;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC721_init("PrimeNFT", "PRIME");
        // incrementing the token id to 1
        // to make sure that the first NFT has an id of 1
        tokenId++;
    }

    /// @notice Creates an NFT to msg.sender
    /// @dev Will revert if 20 NFTs (tokenIds 1-20) have already been minted
    function mint() external {
        require(tokenId <= MAX_SUPPLY, "PrimeNFT: cap reached");

        _mint(msg.sender, tokenId);
        tokenId++;
    }
}

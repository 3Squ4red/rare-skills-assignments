// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeNFT is ERC721Enumerable {
    using Counters for Counters.Counter;
    // This will always hold the next available token id 
    Counters.Counter private tokenId;

    uint public constant MAX_SUPPLY = 20;

    constructor() ERC721("PrimeNFT", "PRIME") {
        // incrementing the token id to 1
        // to make sure that the first NFT has an id of 1
        tokenId.increment();
    }

    /// @notice Creates an NFT to msg.sender
    /// @dev Will revert if 20 NFTs (tokenIds 1-20) have already been minted
    function mint() external {
        require(tokenId.current() <= MAX_SUPPLY, "PrimeNFT: cap reached");

        _mint(msg.sender, tokenId.current());
        tokenId.increment();
    }
}

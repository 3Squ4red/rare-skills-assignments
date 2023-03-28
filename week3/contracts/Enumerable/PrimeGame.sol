// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract PrimeGame {
    IERC721Enumerable public immutable nft;

    constructor(IERC721Enumerable _nft) {
        nft = _nft;
    }

    uint[] private ids;
    /// @notice Gets all the tokenIds owned by an address
    /// @param user The address whose token ids must be fetched
    /// @return An array containing all the token ids owned by `user`
    function getTokenIds(address user) external returns(uint[] memory) {
        delete ids;
        uint tokenCount = nft.balanceOf(user);
        for (uint i = 0; i < tokenCount; i++) {
            ids.push(nft.tokenOfOwnerByIndex(user, i));
        }
        return ids;
    }

    /// @notice Finds the number of NFTs owned by an address whose token id is a prime number
    /// @dev Doesn't use the above getTokenIds function because it's too gas heavy
    /// @param user The address whose NFTs must be checked
    /// @return items The number of NFTs which have prime token ids
    function getItems(address user) external view returns(uint items) {
        uint tokenCount = nft.balanceOf(user);
        for (uint i = 0; i < tokenCount; i++) {
            if(isPrime(nft.tokenOfOwnerByIndex(user, i)))
                items++;
        }
    }

    /// @notice Checks whether a number is prime or not
    /// @param n The number which must be checked
    /// @return true is `n` is prime, false otherwise
    function isPrime(uint256 n) public pure returns (bool) {
        if(n < 2) return false;
        for (uint256 i = 2; i < n; i++) {
            if (n % i == 0) {
                return false;
            }
        }
        return true;
    }
}

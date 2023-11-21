// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// In simplest words, this exercise could be completed by somehow managing to
// make an account hold 5 NFTs
// This can be done in the following manner:
// An address (EOA) calls mint() four times and own the NFTs with token ids 1,2,3,4
// This EOA transfers the 4 ID NFT to his other address
// Now he would be able to mint one more NFT with id 5
// Finally, he would transfer back the 4 ID NFT from his other address
// If he calls the success() at this point it would return `true`
contract Overmint2 is ERC721 {
    using Address for address;
    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

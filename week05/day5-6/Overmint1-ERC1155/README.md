# Overmint1_ERC1155

This too was a simple reentrancy attack but for ERC1155 tokens (or NFTs). The goal was to find a way to mint 5 tokens while there was a restriction on the mint function that the minter must have less than or equal to 3 tokens to be able to mint another one.

The `<=` was the first flaw that allowed anyone to easily mint 4 tokens. But to mint more than that, a reentrancy attack could be done because the balance of an address is updated **AFTER** minting a token to it.

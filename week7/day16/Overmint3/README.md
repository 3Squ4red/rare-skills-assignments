# Overmint 3

This was trickier than the other overmints cause at first glance it looked like a simple reentrancy attack exercise.

Reentrancy is not possible in this one because in order to pass through the first `require`, the call to `mint()` must be made from within a constructor; and while still in constructor, the `_checkOnERC721Received` (internally called within `_safeMint`) function will not call the `onERC721Received` (because it won't recognize the address NFT being minted to as a contract).

Therefore, the only way I could think of is to use 5 separate contracts to call the `mint()` function and then have them all transfer their NFTs to the attacker's address.

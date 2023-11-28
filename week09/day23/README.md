# Reward Token

In `withdrawAndClaimEarnings(uint)` the stakes of the withdrawer is being deleted **after** transferring the NFT to him.
Therefore, reentrancy is possible here.

## How to complete

1. Transfer the NFT from the attack contract to `Depositoor` contract.
2. After nearly 12 days, withdraw back the NFT from `Depositoor`.
3. Inside `onERC721Received`, claim the earnings again for the same NFT

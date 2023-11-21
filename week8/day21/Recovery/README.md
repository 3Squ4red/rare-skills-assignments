# Recovery

We are supposed to drain the token contract of all its ether (0.001). But the problem is, its address is unknown. So we have to figure out two things:

1. The address of the token contract
2. How to take all the ether from it

The second problem has an easy solution: there's a `destroy(address payable)` which is public and without any caller restrictions.

As for the first problem, we have to manually calculate the address of the token contract which was deployed by the factory contract, using the factory's address.
It's done in the following manner:

`address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x01))))));`

Where `_origin` is the deployer (in this case, the factory contract).

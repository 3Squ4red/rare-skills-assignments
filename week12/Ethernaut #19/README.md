S1 - Call `makeContact()`. Because all other function requires the `contact` to be true.

S2 - Call `retract()` to underflow the size of `codex` which expands its length to the entire storage of the contract.

S3 - Figure out the index of `codex` that collides with the slot 0 of the storage. Paste the following in the console.

`let p = web3.utils.keccak256(web3.eth.abi.encodeParameters(["uint256"], [1]))`
`let i = BigInt(2**256) - BigInt(p)`

S4 - Call `revise()` with the `i.toString()` as the first parameter and your address left-padded with zeroes (to make it 32 bytes) as the second parameter.
# Forwarder

Well, that was very simple (thankfully!).

## How to complete

1. Deploy the `Forwarder` contract
2. Deploy the `Wallet` contract passing in the address of the `Forwarder` contract and also send along 1 ether
3. Now to call the `sendEther(address,uint256)` function of `Wallet`, we have to call the `functionCall(address,bytes)` function of `Forwarder` with the address of `Wallet` and the correct bytes data which would call `sendEther(address,uint256)` in such a way that we will get back our 1 ether
4. To get this bytes data, we can use `abi.encodeCall()`

```Solidity
    // you are the receiver
    function getFuncSig(address receiver) external pure returns (bytes memory) {
        return abi.encodeCall(Wallet.sendEther, (receiver, 1 ether));
    }
```

5. Now after getting the bytes data from the `getFuncSig(address)` function, simply call `functionCall(address,bytes)` and you'll get back your money!

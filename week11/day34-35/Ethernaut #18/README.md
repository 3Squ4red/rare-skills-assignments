# RUNTIME CODE:

```JS
// store 42 on memory
PUSH1 0x2a // 0x2a = 42
PUSH1 0x00
MSTORE
// return it
PUSH1 0x20 // 0x20 = 32
PUSH1 0x00
RETURN
```

The above translates to following in bytecode:
`0x602a60005260206000f3`
Which is exactly 10 bytes long.


# CREATION CODE

```js
// store the runtime code on memory
PUSH10 0x602a60005260206000f3
PUSH1 0x00
MSTORE
// return it
PUSH1 0x0a // 0x0a = 10
PUSH1 0x16 // 0x16 = 22
RETURN
```

The above translates to following in bytecode:
`0x69602a60005260206000f3600052600a6016f3`

# Deployment
Open the console and enter the following:

`let tx = await web3.eth.sendTransaction({from: player, data: "69602a60005260206000f3600052600a6016f3"})`

Let this tx go through. Then you can get the address of the deployed contract like this: `tx.contractAddress` and pass it to the `setSolver` function.
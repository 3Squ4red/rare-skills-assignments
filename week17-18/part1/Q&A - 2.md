> When a contract calls another contract via `call`, `delegatecall`, or `staticcall`, how is information passed between them? Where is this data stored?

When a contract calls another contract via `call`, `delegatecall`, or `staticcall`, information is passed between them using the `argsOffset` and `argsSize` parameters of these opcodes. This information/data is first stored the *memory* and then it's starting position and it's total size are passed as `argsOffset` and `argsSize` respectively.

> If a proxy calls an implementation, and the implementation self-destructs in the function that gets called, what happens?

The proxy gets destroyed. It will be as if the `selfdestruct` was called on the proxy itself. 

> If a proxy calls an empty address or an implementation that was previously self-destructed, what happens?

The call succeeds but no data is returned back from the implementation contract.

> If a user calls a proxy that makes a delegatecall to A, and A makes a regular call to B, from A's perspective, who is msg.sender? from B's perspective, who is msg.sender? From the proxy's perspective, who is msg.sender?

```
    call      delegate   call
eoa  ->  proxy   ->   a   ->   b
          eoa        eoa     proxy
```

> If a proxy makes a delegatecall to A, and A does address(this).balance, whose balance is returned, the proxy's or A?

Proxy's

> If a proxy makes a delegatecall to A, and A calls codesize, is codesize the size of the proxy or A?

A

> If a delegatecall is made to a function that reverts, what does the delegatecall do?

It returns 0

> Under what conditions does the Openzeppelin Proxy.sol overwrite the free memory pointer? Why is it safe to do this?

While delegating a call to the implementation contract, if the calldata to be sent or the return data received are larger than 64 bytes, then the free memory pointer is overwritten in OZ's Proxy.sol.
This is safe to do because the entire body of the function is inside an assembly block, hence full control of the memory is taken and Solidity never gets a chance to use/update the free memory pointer.

> If a delegatecall is made to a function that reads from an immutable variable, what will the value be?

Immutables are stored at the contract's bytecode, therefore that function will read the immutable from it's own bytecode and it's value will be the same as to what it was initialized with.

> If a delegatecall is made to a contract that makes a delegatecall to another contract, who is msg.sender in the proxy, the first contract, and the second contract?

In this case, msg.sender for all the three contracts will be the initial caller i.e. an EOA

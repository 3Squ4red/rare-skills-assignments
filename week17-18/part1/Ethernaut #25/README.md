# Motorbike 🏍️

Here, the goal is to `selfdestruct` the **Engine** contract.

# How to complete

S1 - Call `initialize` directly on the **Engine**

... and make yourself the `upgrader`!

Even though, **Engine** is supposed to be used *through* **Motorbike**, nothing is forcing us to do that. And because `upgrader` is actually stored in the **Motorbike**'s storage, we can still make ourselves the `upgrader` on the `Engine`'s storage.

S2 - Create and deploy a contract **Solver** with a function `boom` and just invoke `selfdestruct` inside it
****
```solidity
contract Solver {
    function boom() external {
        selfdestruct(payable(0xD1B9C015FBA1D7B631791A2201411a378fd562e7));
    }
}
```

We'll make the **Engine** `delegatecall` to this contract.

S2 - Call `upgradeToAndCall` passing in the address of the **Solver** and the function selector of `boom`

Since, you're the `upgrader` in the **Engine**'s storage, you have the authorization to call `upgradeToAndCall`.

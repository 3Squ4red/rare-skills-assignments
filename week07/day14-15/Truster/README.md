# Truster

The `flashLoan(uint,address,address,bytes)` function not only issues flash loans, but also calls a function on an address (which is of a contract'). This ability can be used to call the `approve(address,uint)` function on the DVT contract.

So, to drain the pool of all its DVTs, we don't even have to get flash loans from it. Just get approval to spend all of the pool's DVT and transfer it to your address.

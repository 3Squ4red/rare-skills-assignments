# King

Every time an amount greater than or equal to the prize is sent to the `King` contract, the king is changed and the previous king gets the amount he sent to become the king.

To become the king ourselves and not let anyone else become the king again, we can create a contract from which we send in the `prize` amount (which is 0.001 ether) and omit (or revert from) the `receive` of `fallback` function in that contract. By doing this, we are making it impossible for the King contract to send our contract any ethers, which should happen every time the king is changed.

Also, note that while first sending the ethers to the King contract (to become the King), you *must* use the `call` function and **NOT** the `transfer` or `send` because they both would work if the `receive()` function (of the King contract) consumed less than 2300 gas. Unfortunately, it'll consume more than this limit. Therefore instead, use `call()` which consumes all required gas.

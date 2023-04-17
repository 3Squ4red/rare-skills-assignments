# Fallback

There was no need to write any contracts to complete this exercise.

## How to solve

Send a very small amount of ether, say 0.000001 to the contract and pass `d7bb99ba` as the hex data. This is the function signature of `contribute()` which will set your contribution to a non-zero value.
Now, you can directly send the same amount (or any other value) of ether to the contract address which will trigger the receive function and set you as the owner of the contract.

Finally, run `await contract.withdraw()` in the console and drain the contract.

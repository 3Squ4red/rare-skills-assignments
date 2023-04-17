# Predict the future

In this exercise, the guess has to be set beforehand and then settled later. Note that this time too the correct guess in an `uint8` variable but the range has been further reduced by using `% 10`. But still brute force won't work because of `settlementBlockNumber`.

## How to complete

Create another contract through which lock in any guess from 0-10. After this, while settlement, first calculate the answer just like it's done in the challenge contract and then check if it matches with our guess. Only if it does, call the `settle()` function on the challenge contract.

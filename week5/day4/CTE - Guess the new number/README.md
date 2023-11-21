# Guess The New Number Challenge

Since the number is now being generated when a guess is made using global variables like `block.blockhash` and `block.number`, we can write another contract to generate the guess in the exact same way it's generated in the challenge contract.

## How to complete

Write another contract with a function which generates a guess like the challenge contract and then call `guess()` with the same number. Don't forget to pass along 1 ether and also to add a fallback function to the contract so that it can receive ether.

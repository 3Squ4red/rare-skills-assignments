# Guess the secret number

For this one, we didn't have the exact number to start with, but rather it's hash. And a hash is irreversible so brute force was the only option left.

## How to complete

The easiest part was the answer being a `uint8` number. This made brute forcing much faster, as the total possible correct numbers got limited to the range of 0-255 (inclusive).
So to complete, just run a loop checking the hash of each number against the answer hash in the contract and the one whose hash matches would be the correct guess.

P.S. It's 170 👀

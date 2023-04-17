# Guess the random number

For me, this was also an exercise to practice how to read state variables directly from their slot number. The answer was not generated in a secure random way, which was another bug besides storing the answer in the contract itself.

## How to complete

Deploy the contract with 1 ether then get the `answer` stored in slot 0 in the following way:
`let answer = await ethers.provider.getStorageAt(instance.address, 0);`

Now you got the answer you gotta pass to `guess(uint8)`. Just be sure to convert it into decimal format first and also don't forget to pass along 1 ether while calling `guess(uint8)`.

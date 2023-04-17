# Hello ethernaut

The **catch** of this exercise was to check the ABI of the `contract`, and figure out which function to call in order to get the password.

## How to complete

Open the console and run `await contract.info()` and follow the steps.
When you're said _'If you know the password, submit it to authenticate().'_, run `await contract.password()` to get the password. Then simply pass it to `authenticate()`.

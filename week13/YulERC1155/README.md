# Yul developer experience

## Repository installation

1. Install Foundry
```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install solidity compiler
https://docs.soliditylang.org/en/latest/installing-solidity.html#installing-the-solidity-compiler

## Running tests

Run tests (compiles yul then fetch resulting bytecode in test)
```
forge test --via-ir
```

To see the console logs during tests
```
forge test -vvv --via-ir
```

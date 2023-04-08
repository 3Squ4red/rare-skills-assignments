//SPDX-License-Identifier: MIT
/// Solution to the first exercise was to use a Solidity version
/// greater than or equal to 0.8.0
pragma solidity 0.8.17;

contract Ownership {
    address owner = msg.sender;

    /// @notice Solution to the second exercise was to remove this function
    // function Owner() public {
    //     owner = msg.sender;
    // }

    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
}

contract Pausable is Ownership {
    bool is_paused;
    modifier ifNotPaused() {
        require(!is_paused);
        _;
    }

    function paused() public isOwner {
        is_paused = true;
    }

    function resume() public isOwner {
        is_paused = false;
    }
}

contract Token is Pausable {
    mapping(address => uint) public balances;

    function transfer(address to, uint value) public ifNotPaused {
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}

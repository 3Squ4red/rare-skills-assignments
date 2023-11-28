# Unstoppable

No, you don't need to understand ERC4626 (Tokenized vault) and ERC3156 (Flash Loans) to be able to complete this challenge. To me, this looked way more complicated than it is.

`flashLoan(...)` is the only function you need to examine carefully to complete this challenge.

```Solidity
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address _token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        if (amount == 0) revert InvalidAmount(0); // fail early
        if (address(asset) != _token) revert UnsupportedCurrency(); // enforce ERC3156 requirement
        uint256 balanceBefore = totalAssets();
        if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement
        uint256 fee = flashFee(_token, amount);
        // transfer tokens out + execute callback on receiver
        ERC20(_token).safeTransfer(address(receiver), amount);
        // callback must return magic value, otherwise assume it failed
        if (receiver.onFlashLoan(msg.sender, address(asset), amount, fee, data) != keccak256("IERC3156FlashBorrower.onFlashLoan"))
            revert CallbackFailed();
        // pull amount + fee from receiver, then pay the fee to the recipient
        ERC20(_token).safeTransferFrom(address(receiver), address(this), amount + fee);
        ERC20(_token).safeTransfer(feeRecipient, fee);
        return true;
    }
```

Our goal for this one is to make all future calls to this function revert. So, let's fixate our eyes on all the `revert` keywords. Following is the list of reverts in this function:

1. Revert if the `amount` to be lent is 0
2. Revert if the loan is asked for a different token than the one set in the constructor
3. Revert if the number of shares the vault would exchange for the current total shares is not equal to the amount of DVT held by the vault
4. Revert if the lender contract didn't return back the correct *magic value* i.e. `keccak256("IERC3156FlashBorrower.onFlashLoan"))`.

All the reverts except for the third one are controlled by the contract asking for a flash loan. So, to complete this challenge, you can influence the third `revert` condition by simply sending the 10 DVTs (which you were given at the start) to the vault. This would increase its balance and this condition `convertToShares(totalSupply) != balanceBefore` would become true.

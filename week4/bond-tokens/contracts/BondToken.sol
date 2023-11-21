// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";

library BondCurve {
    function calculateBond(
        uint256 weiPaid,
        uint256 weiBalance,
        uint256 bondSupply
    ) external pure returns (uint256 mintAmount) {
        mintAmount = _sqrt(2 * (weiPaid + weiBalance)) - bondSupply;
    }

    function calculateWei(
        uint256 bondSellAmount,
        uint256 weiBalance,
        uint256 bondSupply
    ) external pure returns (uint256 refundAmount) {
        refundAmount = weiBalance - ((bondSupply - bondSellAmount)**2) / 2;
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract BondToken is ERC1363 {
    event Buy(uint256 weiPaid, uint256 bondReceived);
    event Sell(uint256 bondSold, uint256 weiReceived);

    error ZeroMintError(uint256 oneBONDPrice);

    /// @notice This will hold the amount of collateral i.e. wei held by this contract
    uint256 public balance;

    /// @notice Sets the token name and symbol
    constructor() ERC20("Bond Token", "BOND") {}

    /// @notice User facing buy function
    function buy() external payable {
        _buy(msg.value);
    }

    /// @notice User facing sell function to sell off their tokens
    /// @dev burns `bondAmount` tokens from msg.sender's balance
    /// @param bondAmount Amount of tokens to `sell`
    function sell(uint256 bondAmount) external {
        _sell(msg.sender, bondAmount);
    }

    /// @dev Internal function to `buy` BOND
    /// @dev emits `Buy(weiPaid, bondReceived)`
    /// @param deposit Amount in wei which a user pays for BOND tokens in return
    function _buy(uint256 deposit) private {
        require(deposit > 0, "BOND: pay something");

        uint256 bondAmount = BondCurve.calculateBond(
            deposit,
            balance,
            totalSupply()
        );
        // revert if the no. of BOND user will get is 0
        if (bondAmount == 0) revert ZeroMintError(getPrice(1));
        balance += deposit;
        _mint(msg.sender, bondAmount);

        emit Buy(deposit, bondAmount);
    }

    /// @dev Internal function to `sell` BOND
    /// @dev emits `Sell(bondSold, weiReceived)`
    /// @param seller The address who's selling tokens
    /// @param bondAmount The amount of tokens being sold
    function _sell(address seller, uint256 bondAmount) private {
        require(bondAmount > 0, "BOND: must be non-zero");

        uint256 refundAmount = BondCurve.calculateWei(
            bondAmount,
            balance,
            totalSupply()
        );
        balance -= refundAmount;
        _burn(seller, bondAmount);

        // finally transfer the amount
        payable(msg.sender).transfer(refundAmount);

        emit Sell(bondAmount, refundAmount);
    }

    /// @notice Gets the price of `bondAmount` tokens in wei
    /// @param bondAmount Amount of BOND tokens to fetch the price of
    /// @return price The amount of wei to be paid for `bondAmount` tokens
    function getPrice(uint256 bondAmount) public view returns (uint256 price) {
        price = BondCurve.calculateWei(bondAmount, balance, totalSupply());
    }

    /// @dev See {ERC20-decimals}
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /// @notice Users can buy BOND by directly sending wei
    receive() external payable {
        _buy(msg.value);
    }

    
    /// @notice Repays the spender for `amount` BOND
    /// @dev See {ERC20-_afterTokenTransfer}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (to == address(this)) {
            _sell(from, amount);
        }
    }
}

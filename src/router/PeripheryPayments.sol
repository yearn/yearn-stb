// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 @title Periphery Payments
 @notice Immutable state used by periphery contracts
 Largely Forked from https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/PeripheryPayments.sol 
 Changes:
 * no interface
 * no inheritdoc
 * add immutable WETH9 in constructor instead of PeripheryImmutableState
 * receive from any address
 * Solmate interfaces and transfer lib
 * casting
 * add approve, wrapWETH9 and pullToken
*/
abstract contract PeripheryPayments {
    using SafeERC20 for *;

    IWETH9 public immutable WETH9;

    constructor(address _WETH9) {
        WETH9 = IWETH9(_WETH9);
    }

    receive() external payable {}

    function approve(ERC20 token, address to, uint256 amount) public payable {
        token.forceApprove(to, amount);
    }

    function unwrapWETH9(
        uint256 amountMinimum,
        address recipient
    ) public payable {
        uint256 balanceWETH9 = WETH9.balanceOf(address(this));
        require(balanceWETH9 >= amountMinimum, "Insufficient WETH9");

        if (balanceWETH9 > 0) {
            WETH9.withdraw(balanceWETH9);
            safeTransferETH(recipient, balanceWETH9);
        }
    }

    function wrapWETH9() public payable {
        if (address(this).balance > 0)
            WETH9.deposit{value: address(this).balance}(); // wrap everything
    }

    function pullToken(
        ERC20 token,
        uint256 amount,
        address recipient
    ) public payable {
        token.safeTransferFrom(msg.sender, recipient, amount);
    }

    function sweepToken(
        ERC20 token,
        uint256 amountMinimum,
        address recipient
    ) public payable {
        uint256 balanceToken = token.balanceOf(address(this));
        require(balanceToken >= amountMinimum, "Insufficient token");

        if (balanceToken > 0) {
            token.safeTransfer(recipient, balanceToken);
        }
    }

    function refundETH() external payable {
        if (address(this).balance > 0)
            safeTransferETH(msg.sender, address(this).balance);
    }

    // From https://github.com/transmissions11/solmate/blob/9f16db2144cc9a7e2ffc5588d4bf0b66784283bd/src/utils/SafeTransferLib.sol
    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }
}

abstract contract IWETH9 is ERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable virtual;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external virtual;
}

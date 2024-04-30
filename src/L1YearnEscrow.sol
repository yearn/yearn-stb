// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IVault} from "@yearn-vaults/interfaces/IVault.sol";
import {L1Escrow, SafeERC20, IERC20} from "@zkevm-stb/L1Escrow.sol";

/**
 * @title L1YearnEscrow
 * @author yearn.fi
 * @dev L1 escrow that will deploy the assets to a Yearn vault to earn yield.
 */
contract L1YearnEscrow is L1Escrow {
    // ****************************
    // *         Libraries        *
    // ****************************

    using SafeERC20 for IERC20;

    // ****************************
    // *         Events         *
    // **************************

    /**
     * @dev Emitted when the Vault is updated.
     */
    event UpdateVaultAddress(address indexed newVaultAddress);

    /**
     * @dev Emitted when the minimum buffer is updated.
     */
    event UpdateMinimumBuffer(uint256 newMinimumBuffer);

    // ****************************
    // *      ERC-7201 Storage    *
    // **************************

    /// @custom:storage-location erc7201:yearn.storage.vault
    struct VaultStorage {
        IVault vaultAddress;
        uint256 minimumBuffer;
    }

    // keccak256(abi.encode(uint256(keccak256("yearn.storage.vault")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant VaultStorageLocation =
        0xff1003c0fa1e6064b336121b432b179c1b66edc6a2d9068cade1ea1361605700;

    function _getVaultStorage() private pure returns (VaultStorage storage $) {
        assembly {
            $.slot := VaultStorageLocation
        }
    }

    function vaultAddress() public view returns (address) {
        VaultStorage storage $ = _getVaultStorage();
        return address($.vaultAddress);
    }

    function minimumBuffer() public view returns (uint256) {
        VaultStorage storage $ = _getVaultStorage();
        return $.minimumBuffer;
    }

    // ****************************
    // *        Initializer       *
    // ****************************

    /**
     * @notice L1YearnEscrow initializer
     * @param _admin The admin address
     * @param _manager The escrow manager address
     * @param _polygonZkEVMBridge Polygon ZkEVM bridge address
     * @param _counterpartContract Counterpart contract
     * @param _counterpartNetwork Counterpart network
     * @param _originTokenAddress Token address
     * @param _wrappedTokenAddress L2Token address on Polygon ZkEVM
     * @param _vaultAddress Address of the vault to use.
     */
    function initialize(
        address _admin,
        address _manager,
        address _polygonZkEVMBridge,
        address _counterpartContract,
        uint32 _counterpartNetwork,
        address _originTokenAddress,
        address _wrappedTokenAddress,
        address _vaultAddress
    ) public virtual initializer {
        // Initialize the default escrow.
        initialize(
            _admin,
            _manager,
            _polygonZkEVMBridge,
            _counterpartContract,
            _counterpartNetwork,
            _originTokenAddress,
            _wrappedTokenAddress
        );

        VaultStorage storage $ = _getVaultStorage();
        // Max approve the vault
        originTokenAddress().forceApprove(_vaultAddress, 2 ** 256 - 1);
        // Set the vault variable
        $.vaultAddress = IVault(_vaultAddress);
    }

    // ****************************
    // *           Bridge         *
    // ****************************

    /**
     * @dev Handle the reception of the tokens
     * @param amount Token amount
     */
    function _receiveTokens(
        uint256 amount
    ) internal virtual override whenNotPaused {
        originTokenAddress().safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        VaultStorage storage $ = _getVaultStorage();
        uint256 _minimumBuffer = $.minimumBuffer;
        // Deposit to the vault if above buffer
        if (_minimumBuffer != 0) {
            uint256 underlyingBalance = originTokenAddress().balanceOf(
                address(this)
            );

            if (underlyingBalance <= _minimumBuffer) return;

            unchecked {
                amount = underlyingBalance - _minimumBuffer;
            }
        }

        $.vaultAddress.deposit(amount, address(this));
    }

    /**
     * @dev Handle the transfer of the tokens. Will send shares instead of
     *      the underlying asset if the vault is illiquid.
     * @param destinationAddress Address destination that will receive the tokens on the other network
     * @param amount Token amount
     */
    function _transferTokens(
        address destinationAddress,
        uint256 amount
    ) internal virtual override whenNotPaused {
        IERC20 originToken = originTokenAddress();

        // Check if there is enough buffer.
        uint256 underlyingBalance = originToken.balanceOf(address(this));
        if (underlyingBalance >= amount) {
            // Only use buffer if it covers the full amount.
            originToken.safeTransfer(destinationAddress, amount);
            return;
        }

        // Check if the vault will allow for a full withdraw.
        IVault _vault = _getVaultStorage().vaultAddress;
        uint256 maxWithdraw = _vault.maxWithdraw(address(this));
        // If liquidity will not allow for a full withdraw.
        if (amount > maxWithdraw) {
            // First use any loose balance.
            if (underlyingBalance != 0) {
                originToken.safeTransfer(destinationAddress, underlyingBalance);
                unchecked {
                    amount = amount - underlyingBalance;
                }
            }

            // Check again to account for if there was underlying
            if (amount > maxWithdraw) {
                // Send an equivalent amount of shares for the difference.
                uint256 shares = _vault.convertToShares(amount - maxWithdraw);
                _vault.transfer(destinationAddress, shares);
                if (maxWithdraw == 0) return;
                amount = maxWithdraw;
            }
        }

        // Withdraw from vault to receiver.
        _vault.withdraw(amount, destinationAddress, address(this));
    }

    // ****************************
    // *          Manager         *
    // ****************************

    /**
     * @dev Escrow manager can withdraw the token backing
     * @param _recipient the recipient address
     * @param _amount The amount of token in underlying
     */
    function withdraw(
        address _recipient,
        uint256 _amount
    ) external virtual override onlyRole(ESCROW_MANAGER_ROLE) whenNotPaused {
        IVault _vault = _getVaultStorage().vaultAddress;
        // Transfer the equivalent amount of vault shares
        uint256 shares = _vault.convertToShares(_amount);
        _vault.transfer(_recipient, shares);

        emit Withdraw(_recipient, _amount);
    }

    // ****************************
    // *          Admin         *
    // ****************************

    /**
     * @dev Update the vault to deploy funds into.
     *      Will fully withdraw from the old vault.
     * @param _vaultAddress Address of the new vault to use.
     */
    function updateVault(
        address _vaultAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        VaultStorage storage $ = _getVaultStorage();
        IVault oldVault = $.vaultAddress;
        IERC20 originToken = originTokenAddress();

        // If re-initializing to a new vault address.
        if (address(oldVault) != address(0)) {
            // Lower allowance to 0
            originToken.forceApprove(address(oldVault), 0);

            uint256 balance = oldVault.balanceOf(address(this));
            // Withdraw the full balance of the current vault.
            if (balance != 0) {
                oldVault.redeem(balance, address(this), address(this));
            }
        }

        // Migrate to new vault if applicable
        if (_vaultAddress != address(0)) {
            // Max approve the new vault
            originToken.forceApprove(_vaultAddress, 2 ** 256 - 1);

            // Deposit any loose funds over minimum buffer
            uint256 balance = originToken.balanceOf(address(this));
            uint256 minimumBuffer = $.minimumBuffer;
            if (balance > minimumBuffer)
                IVault(_vaultAddress).deposit(
                    balance - minimumBuffer,
                    address(this)
                );
        }

        // Update Storage
        $.vaultAddress = IVault(_vaultAddress);
        emit UpdateVaultAddress(_vaultAddress);
    }

    /**
     * @dev Update the minimum buffer to keep in the escrow.
     * @param _minimumBuffer The new minimum buffer to enforce.
     */
    function updateMinimumBuffer(
        uint256 _minimumBuffer
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        VaultStorage storage $ = _getVaultStorage();
        $.minimumBuffer = _minimumBuffer;

        emit UpdateMinimumBuffer(_minimumBuffer);
    }
}

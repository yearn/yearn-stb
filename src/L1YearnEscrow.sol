// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L1Escrow} from "@zkevm-stb/L1Escrow.sol";
import {IVault} from "@yearn-vaults/interfaces/IVault.sol";

// ADD buffer
contract L1YearnEscrow is L1Escrow {
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

    function vaultAddress() public view returns (IVault) {
        VaultStorage storage $ = _getVaultStorage();
        return $.vaultAddress;
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
     * @param _minimumBuffer Buffer if any to keep idle.
     */
    function initialize(
        address _admin,
        address _manager,
        address _polygonZkEVMBridge,
        address _counterpartContract,
        uint32 _counterpartNetwork,
        address _originTokenAddress,
        address _wrappedTokenAddress,
        address _vaultAddress,
        uint256 _minimumBuffer
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
        // Set the vault variables
        $.vaultAddress = IVault(_vaultAddress);
        $.minimumBuffer = _minimumBuffer;
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
        super._receiveTokens(amount);
        VaultStorage storage $ = _getVaultStorage();
        uint256 _minimumBuffer = $.minimumBuffer;
        // Deposit to the vault if above buffer
        if (_minimumBuffer != 0) {
            uint256 underlyingBalance = originTokenAddress().balanceOf(
                address(this)
            );
            if (underlyingBalance <= _minimumBuffer) {
                return;
            }

            unchecked {
                amount = underlyingBalance - _minimumBuffer;
            }
        }

        $.vaultAddress.deposit(amount, address(this));
    }

    /**
     * @dev Handle the transfer of the tokens
     * @param destinationAddress Address destination that will receive the tokens on the other network
     * @param amount Token amount
     */
    function _transferTokens(
        address destinationAddress,
        uint256 amount
    ) internal virtual override whenNotPaused {
        // Withdraw from vault to receiver.
        VaultStorage storage $ = _getVaultStorage();
        uint256 underlyingBalance = originTokenAddress().balanceOf(
            address(this)
        );
        if (underlyingBalance != 0) {
            if (underlyingBalance > amount) {
                super._transferTokens(destinationAddress, amount);
                return;
            } else {
                super._transferTokens(destinationAddress, underlyingBalance);
                unchecked {
                    amount = amount - underlyingBalance;
                }
            }
        }

        $.vaultAddress.withdraw(amount, destinationAddress, address(this));
    }

    // ****************************
    // *          Manager         *
    // ****************************

    /**
     * @dev Escrow manager can withdraw the token backing
     * @param _recipient the recipient address
     * @param _amount The amount of token
     */
    function withdraw(
        address _recipient,
        uint256 _amount
    ) external virtual override onlyRole(ESCROW_MANAGER_ROLE) whenNotPaused {
        VaultStorage storage $ = _getVaultStorage();
        uint256 shares = $.vaultAddress.convertToShares(_amount);
        $.vaultAddress.transfer(_recipient, shares);
        emit Withdraw(_recipient, _amount);
    }

    // ****************************
    // *          Admin         *
    // ****************************

    function updateVault(
        address _vaultAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        VaultStorage storage $ = _getVaultStorage();
        IVault oldVault = $.vaultAddress;
        // If re-initializing to a new vault address.
        if (address(oldVault) != address(0)) {
            uint256 balance = oldVault.balanceOf(address(this));
            // Withdraw the full balance of the current vault.
            if (balance != 0) {
                oldVault.redeem(balance, address(this), address(this));
            }
        }
        $.vaultAddress = IVault(_vaultAddress);

        emit UpdateVaultAddress(_vaultAddress);
    }

    function updateMinimumBuffer(
        uint256 _minimumBuffer
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        VaultStorage storage $ = _getVaultStorage();
        $.minimumBuffer = _minimumBuffer;

        emit UpdateMinimumBuffer(_minimumBuffer);
    }
}

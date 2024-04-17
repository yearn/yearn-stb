// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.8.18;

/// @title IAccountant.
interface IAccountant {
    /// @notice An event emitted when a vault is added or removed.
    event VaultChanged(address indexed vault, ChangeType change);

    /// @notice An event emitted when the default fee configuration is updated.
    event UpdateDefaultFeeConfig(Fee defaultFeeConfig);

    /// @notice An event emitted when the future fee manager is set.
    event SetFutureFeeManager(address indexed futureFeeManager);

    /// @notice An event emitted when a new fee manager is accepted.
    event NewFeeManager(address indexed feeManager);

    /// @notice An event emitted when a new vault manager is set.
    event UpdateVaultManager(address indexed newVaultManager);

    /// @notice An event emitted when the fee recipient is updated.
    event UpdateFeeRecipient(
        address indexed oldFeeRecipient,
        address indexed newFeeRecipient
    );

    /// @notice An event emitted when a custom fee configuration is updated.
    event UpdateCustomFeeConfig(address indexed vault, Fee custom_config);

    /// @notice An event emitted when a custom fee configuration is removed.
    event RemovedCustomFeeConfig(address indexed vault);

    /// @notice An event emitted when the `maxLoss` parameter is updated.
    event UpdateMaxLoss(uint256 maxLoss);

    /// @notice An event emitted when rewards are distributed.
    event DistributeRewards(address indexed token, uint256 rewards);

    /// @notice Enum defining change types (added or removed).
    enum ChangeType {
        NULL,
        ADDED,
        REMOVED
    }

    /// @notice Struct representing fee details.
    struct Fee {
        uint16 managementFee; // Annual management fee to charge.
        uint16 performanceFee; // Performance fee to charge.
        uint16 refundRatio; // Refund ratio to give back on losses.
        uint16 maxFee; // Max fee allowed as a percent of gain.
        uint16 maxGain; // Max percent gain a strategy can report.
        uint16 maxLoss; // Max percent loss a strategy can report.
        bool custom; // Flag to set for custom configs.
    }

    /// @notice The amount of max loss to use when redeeming from vaults.
    function maxLoss() external view returns (uint256);

    /// @notice The address of the fee manager.
    function feeManager() external view returns (address);

    /// @notice The address of the fee recipient.
    function feeRecipient() external view returns (address);

    /// @notice An address that can add or remove vaults.
    function vaultManager() external view returns (address);

    /// @notice The address of the future fee manager.
    function futureFeeManager() external view returns (address);

    /// @notice The default fee configuration.
    function defaultConfig() external view returns (Fee memory);

    /// @notice Mapping to track added vaults.
    function vaults(address) external view returns (bool);

    /// @notice Mapping vault => custom Fee config if any.
    function customConfig(address) external view returns (Fee memory);

    /// @notice Mapping vault => strategy => flag for one time healthcheck skips.
    function skipHealthCheck(address, address) external view returns (bool);

    /**
     * @notice Called by a vault when a `strategy` is reporting.
     * @dev The msg.sender must have been added to the `vaults` mapping.
     * @param strategy Address of the strategy reporting.
     * @param gain Amount of the gain if any.
     * @param loss Amount of the loss if any.
     * @return totalFees if any to charge.
     * @return totalRefunds if any for the vault to pull.
     */
    function report(
        address strategy,
        uint256 gain,
        uint256 loss
    ) external returns (uint256 totalFees, uint256 totalRefunds);

    /**
     * @notice Function to add a new vault for this accountant to charge fees for.
     * @dev This is not used to set any of the fees for the specific vault or strategy. Each fee will be set separately.
     * @param vault The address of a vault to allow to use this accountant.
     */
    function addVault(address vault) external;

    /**
     * @notice Function to remove a vault from this accountant's fee charging list.
     * @param vault The address of the vault to be removed from this accountant.
     */
    function removeVault(address vault) external;
    /**
     * @notice Function to update the default fee configuration used for 
        all strategies that don't have a custom config set.
     * @param defaultManagement Default annual management fee to charge.
     * @param defaultPerformance Default performance fee to charge.
     * @param defaultRefund Default refund ratio to give back on losses.
     * @param defaultMaxFee Default max fee to allow as a percent of gain.
     * @param defaultMaxGain Default max percent gain a strategy can report.
     * @param defaultMaxLoss Default max percent loss a strategy can report.
     */
    function updateDefaultConfig(
        uint16 defaultManagement,
        uint16 defaultPerformance,
        uint16 defaultRefund,
        uint16 defaultMaxFee,
        uint16 defaultMaxGain,
        uint16 defaultMaxLoss
    ) external;

    /**
     * @notice Function to set a custom fee configuration for a specific vault.
     * @param vault The vault the strategy is hooked up to.
     * @param customManagement Custom annual management fee to charge.
     * @param customPerformance Custom performance fee to charge.
     * @param customRefund Custom refund ratio to give back on losses.
     * @param customMaxFee Custom max fee to allow as a percent of gain.
     * @param customMaxGain Custom max percent gain a strategy can report.
     * @param customMaxLoss Custom max percent loss a strategy can report.
     */
    function setCustomConfig(
        address vault,
        uint16 customManagement,
        uint16 customPerformance,
        uint16 customRefund,
        uint16 customMaxFee,
        uint16 customMaxGain,
        uint16 customMaxLoss
    ) external;

    /**
     * @notice Function to remove a previously set custom fee configuration for a vault.
     * @param vault The vault to remove custom setting for.
     */
    function removeCustomConfig(address vault) external;

    /**
     * @notice Turn off the health check for a specific `vault` `strategy` combo.
     * @dev This will only last for one report and get automatically turned back on.
     * @param vault Address of the vault.
     * @param strategy Address of the strategy.
     */
    function turnOffHealthCheck(address vault, address strategy) external;

    /**
     * @notice Public getter to check for custom setting.
     * @dev We use uint256 for the flag since its cheaper so this
     *   will convert it to a bool for easy view functions.
     *
     * @param vault Address of the vault.
     * @return If a custom fee config is set.
     */
    function useCustomConfig(address vault) external view returns (bool);

    /**
     * @notice Get the full config used for a specific `vault`.
     * @param vault Address of the vault.
     * @return fee The config that would be used during the report.
     */
    function getVaultConfig(
        address vault
    ) external view returns (Fee memory fee);

    /**
     * @notice Function to redeem the underlying asset from a vault.
     * @dev Will default to using the full balance of the vault.
     * @param vault The vault to redeem from.
     */
    function redeemUnderlying(address vault) external;

    /**
     * @notice Function to redeem the underlying asset from a vault.
     * @param vault The vault to redeem from.
     * @param amount The amount in vault shares to redeem.
     */
    function redeemUnderlying(address vault, uint256 amount) external;

    /**
     * @notice Sets the `maxLoss` parameter to be used on redeems.
     * @param _maxLoss The amount in basis points to set as the maximum loss.
     */
    function setMaxLoss(uint256 _maxLoss) external;

    /**
     * @notice Function to distribute all accumulated fees to the designated recipient.
     * @param token The token to distribute.
     */
    function distribute(address token) external;

    /**
     * @notice Function to distribute accumulated fees to the designated recipient.
     * @param token The token to distribute.
     * @param amount amount of token to distribute.
     */
    function distribute(address token, uint256 amount) external;

    /**
     * @notice Function to set a future fee manager address.
     * @param _futureFeeManager The address to set as the future fee manager.
     */
    function setFutureFeeManager(address _futureFeeManager) external;

    /**
     * @notice Function to accept the role change and become the new fee manager.
     * @dev This function allows the future fee manager to accept the role change and become the new fee manager.
     */
    function acceptFeeManager() external;
    /**
     * @notice Function to set a new vault manager.
     * @param newVaultManager Address to add or remove vaults.
     */
    function setVaultManager(address newVaultManager) external;

    /**
     * @notice Function to set a new address to receive distributed rewards.
     * @param newFeeRecipient Address to receive distributed fees.
     */
    function setFeeRecipient(address newFeeRecipient) external;
}

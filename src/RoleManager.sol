// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Roles} from "@yearn-vaults/interfaces/Roles.sol";
import {IVault} from "@yearn-vaults/interfaces/IVault.sol";
import {IAccountant} from "./interfaces/Yearn/IAccountant.sol";
import {Registry} from "@vault-periphery/registry/Registry.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DebtAllocatorFactory} from "@vault-periphery/debtAllocators/DebtAllocatorFactory.sol";

/// @title PolyYearn Stake the Bridge Role Manager.
contract RoleManager {
    /// @notice Revert message for when a contract has already been deployed.
    error AlreadyDeployed(address _contract);

    /// @notice Emitted when a new vault has been deployed or added.
    event AddedNewVault(
        address indexed vault,
        address indexed debtAllocator,
        uint32 rollupID
    );

    /// @notice Emitted when a vaults debt allocator is updated.
    event UpdateDebtAllocator(
        address indexed vault,
        address indexed debtAllocator
    );

    /// @notice Emitted when a new address is set for a position.
    event UpdatePositionHolder(
        bytes32 indexed position,
        address indexed newAddress
    );

    /// @notice Emitted when a vault is removed.
    event RemovedVault(address indexed vault);

    /// @notice Emitted when a new set of roles is set for a position
    event UpdatePositionRoles(bytes32 indexed position, uint256 newRoles);

    /// @notice Emitted when the defaultProfitMaxUnlock variable is updated.
    event UpdateDefaultProfitMaxUnlock(uint256 newDefaultProfitMaxUnlock);

    /// @notice Position struct
    struct Position {
        address holder;
        uint96 roles;
    }

    /// @notice Config that holds all vault info.
    struct VaultConfig {
        address asset;
        uint32 rollupID; // 0 == default.
        address debtAllocator;
        uint256 index;
    }

    /// @notice Only allow position holder to call.
    modifier onlyPositionHolder(bytes32 _positionId) {
        _isPositionHolder(_positionId);
        _;
    }

    /// @notice Check if the msg sender is specified position holder.
    function _isPositionHolder(bytes32 _positionId) internal view virtual {
        require(msg.sender == getPositionHolder(_positionId), "!allowed");
    }

    /// @notice Rollup ID to use for the default vaults.
    uint32 internal constant DEFAULT_ID = 0;

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    /// @notice Position ID for "Czar".
    bytes32 public constant CZAR = keccak256("Czar");
    /// @notice Position ID for "Keeper".
    bytes32 public constant KEEPER = keccak256("Keeper");
    /// @notice Position ID for "Management".
    bytes32 public constant MANAGEMENT = keccak256("Management");
    /// @notice Position ID for "Governator".
    bytes32 public constant GOVERNATOR = keccak256("Governator");
    /// @notice Position ID for "Emergency Admin".
    bytes32 public constant EMERGENCY_ADMIN = keccak256("Emergency Admin");
    /// @notice Position ID for "Pending Governator".
    bytes32 public constant PENDING_GOVERNATOR =
        keccak256("Pending Governator");

    /// @notice Position ID for the Registry.
    bytes32 public constant REGISTRY = keccak256("Registry");
    /// @notice Position ID for the Accountant.
    bytes32 public constant ACCOUNTANT = keccak256("Accountant");
    /// @notice Position ID for Debt Allocator
    bytes32 public constant DEBT_ALLOCATOR = keccak256("Debt Allocator");
    /// @notice Position ID for the Allocator Factory.
    bytes32 public constant ALLOCATOR_FACTORY = keccak256("Allocator Factory");

    /// @notice Immutable address that the RoleManager position
    // will be transferred to when a vault is removed.
    address public immutable chad;

    /*//////////////////////////////////////////////////////////////
                           STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Array storing addresses of all managed vaults.
    address[] public vaults;

    /// @notice Default time until profits are fully unlocked for new vaults.
    uint256 public defaultProfitMaxUnlock = 10 days;

    /// @notice Mapping of position ID to position information.
    mapping(bytes32 => Position) internal _positions;

    /// @notice Mapping of vault addresses to its config.
    mapping(address => VaultConfig) public vaultConfig;

    /// @notice Mapping of underlying asset => rollupID => vault address.
    /// NOTE: We use 0 for the default vaults since that should never be an L2 ID.
    mapping(address => mapping(uint32 => address)) internal _assetToVault;

    constructor(
        address _governator,
        address _czar,
        address _management,
        address _emergencyAdmin,
        address _keeper,
        address _registry,
        address _allocatorFactory
    ) {
        chad = _czar;

        // Governator gets no roles.
        _positions[GOVERNATOR].holder = _governator;

        // Czar gets all of the Roles.
        _positions[CZAR] = Position({holder: _czar, roles: uint96(Roles.ALL)});

        // Set up the initial role configs for each position.
        _positions[MANAGEMENT] = Position({
            holder: _management,
            roles: uint96(
                Roles.REPORTING_MANAGER |
                    Roles.DEBT_MANAGER |
                    Roles.QUEUE_MANAGER |
                    Roles.DEPOSIT_LIMIT_MANAGER |
                    Roles.DEBT_PURCHASER |
                    Roles.PROFIT_UNLOCK_MANAGER
            )
        });

        // Emergency Admin can set the max debt for strategies to have.
        _positions[EMERGENCY_ADMIN] = Position({
            holder: _emergencyAdmin,
            roles: uint96(Roles.EMERGENCY_MANAGER)
        });

        // The keeper can process reports.
        _positions[KEEPER] = Position({
            holder: _keeper,
            roles: uint96(Roles.REPORTING_MANAGER)
        });

        // Debt allocators manage debt and also need to process reports.
        _positions[DEBT_ALLOCATOR].roles = uint96(
            Roles.REPORTING_MANAGER | Roles.DEBT_MANAGER
        );

        // Set the registry
        _positions[REGISTRY].holder = _registry;
        _positions[ALLOCATOR_FACTORY].holder = _allocatorFactory;
    }

    /*//////////////////////////////////////////////////////////////
                           VAULT CREATION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new endorsed vault.
     * @param _rollupID Id of the rollup to deploy for.
     * @param _asset Address of the underlying asset.
     * @return _vault Address of the newly created vault.
     */
    function _newVault(
        uint32 _rollupID,
        address _asset
    ) internal virtual returns (address _vault) {
        // Append the rollup ID for the name and symbol of custom vaults.
        string memory _id = _rollupID == DEFAULT_ID
            ? ""
            : string(abi.encodePacked("-", Strings.toString(_rollupID)));
        // Name is "{SYMBOL}-STB yVault"
        string memory _name = string(
            abi.encodePacked(ERC20(_asset).symbol(), "-STB", _id, " yVault")
        );
        // Symbol is "stb{SYMBOL}".
        string memory _symbol = string(
            abi.encodePacked("stb", ERC20(_asset).symbol(), _id)
        );

        // Deploy through the registry so it is automatically endorsed.
        _vault = Registry(getPositionHolder(REGISTRY)).newEndorsedVault(
            _asset,
            _name,
            _symbol,
            address(this),
            defaultProfitMaxUnlock
        );

        // Deploy a new debt allocator for the vault.
        address _debtAllocator = _deployAllocator(_vault);

        // Give out roles on the new vault.
        _sanctify(_vault, _debtAllocator);

        // Set up the accountant.
        _setAccountant(_vault);

        // Set deposit limit to max uint.
        _setDepositLimit(_vault, 2 ** 256 - 1);

        // Add the vault config to the mapping.
        vaultConfig[_vault] = VaultConfig({
            asset: _asset,
            rollupID: _rollupID,
            debtAllocator: _debtAllocator,
            index: vaults.length
        });

        // Add the vault to the mapping.
        _assetToVault[_asset][_rollupID] = _vault;

        // Add the vault to the array.
        vaults.push(_vault);

        // Emit event for new vault.
        emit AddedNewVault(_vault, _debtAllocator, _rollupID);
    }

    /**
     * @dev Deploys a debt allocator for the specified vault.
     * @param _vault Address of the vault.
     * @return _debtAllocator Address of the deployed debt allocator.
     */
    function _deployAllocator(
        address _vault
    ) internal virtual returns (address _debtAllocator) {
        address factory = getPositionHolder(ALLOCATOR_FACTORY);

        // If we have a factory set.
        if (factory != address(0)) {
            // Deploy a new debt allocator for the vault with Management as the gov.
            _debtAllocator = DebtAllocatorFactory(factory).newDebtAllocator(
                _vault
            );
        } else {
            // If no factory is set we should be using one central allocator.
            _debtAllocator = getPositionHolder(DEBT_ALLOCATOR);
        }
    }

    /**
     * @dev Assigns roles to the newly added vault.
     *
     * This will override any previously set roles for the holders. But not effect
     * the roles held by other addresses.
     *
     * @param _vault Address of the vault to sanctify.
     * @param _debtAllocator Address of the debt allocator for the vault.
     */
    function _sanctify(
        address _vault,
        address _debtAllocator
    ) internal virtual {
        // Set the roles for the Czar.
        _setRole(_vault, _positions[CZAR]);

        // Set the roles for Management.
        _setRole(_vault, _positions[MANAGEMENT]);

        // Set the roles for EMERGENCY_ADMIN.
        _setRole(_vault, _positions[EMERGENCY_ADMIN]);

        // Set the roles for the Keeper.
        _setRole(_vault, _positions[KEEPER]);

        // Give the specific debt allocator its roles.
        _setRole(
            _vault,
            Position(_debtAllocator, _positions[DEBT_ALLOCATOR].roles)
        );
    }

    /**
     * @dev Used internally to set the roles on a vault for a given position.
     *   Will not set the roles if the position holder is address(0).
     *   This does not check that the roles are !=0 because it is expected that
     *   the holder will be set to 0 if the position is not being used.
     *
     * @param _vault Address of the vault.
     * @param _position Holder address and roles to set.
     */
    function _setRole(
        address _vault,
        Position memory _position
    ) internal virtual {
        if (_position.holder != address(0)) {
            IVault(_vault).set_role(_position.holder, uint256(_position.roles));
        }
    }

    /**
     * @dev Sets the accountant on the vault and adds the vault to the accountant.
     *   This temporarily gives the `ACCOUNTANT_MANAGER` role to this contract.
     * @param _vault Address of the vault to set up the accountant for.
     */
    function _setAccountant(address _vault) internal virtual {
        // Get the current accountant.
        address accountant = getPositionHolder(ACCOUNTANT);

        // If there is an accountant set.
        if (accountant != address(0)) {
            // Temporarily give this contract the ability to set the accountant.
            IVault(_vault).add_role(address(this), Roles.ACCOUNTANT_MANAGER);

            // Set the account on the vault.
            IVault(_vault).set_accountant(accountant);

            // Take away the role.
            IVault(_vault).remove_role(address(this), Roles.ACCOUNTANT_MANAGER);

            // Whitelist the vault in the accountant.
            IAccountant(accountant).addVault(_vault);
        }
    }

    /**
     * @dev Used to set an initial deposit limit when a new vault is deployed.
     *   Any further updates to the limit will need to be done by an address that
     *   holds the `DEPOSIT_LIMIT_MANAGER` role.
     * @param _vault Address of the newly deployed vault.
     * @param _depositLimit The deposit limit to set.
     */
    function _setDepositLimit(
        address _vault,
        uint256 _depositLimit
    ) internal virtual {
        // Temporarily give this contract the ability to set the deposit limit.
        IVault(_vault).add_role(address(this), Roles.DEPOSIT_LIMIT_MANAGER);

        // Set the initial deposit limit on the vault.
        IVault(_vault).set_deposit_limit(_depositLimit);

        // Take away the role.
        IVault(_vault).remove_role(address(this), Roles.DEPOSIT_LIMIT_MANAGER);
    }

    /*//////////////////////////////////////////////////////////////
                            VAULT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new vault to the RoleManager with the specified category and debt allocator.
     * @dev If not already endorsed this function will endorse the vault.
     * @param _rollupID rollupID for the vault to use.
     * @param _vault Address of the vault to be added.
     */
    function _addNewVault(uint32 _rollupID, address _vault) public virtual {
        // If not the current role manager.
        if (IVault(_vault).role_manager() != address(this)) {
            // Accept the position of role manager.
            IVault(_vault).accept_role_manager();
        }

        // Deploy a new Debt Allocator.
        address _debtAllocator = _deployAllocator(_vault);

        // Get the current registry.
        address registry = getPositionHolder(REGISTRY);

        // Check if the vault has been endorsed yet in the registry.
        if (!Registry(registry).isEndorsed(_vault)) {
            // If not endorse it.
            // NOTE: This will revert if adding a vault of an older version.
            Registry(registry).endorseMultiStrategyVault(_vault);
        }

        // Set the roles up.
        _sanctify(_vault, _debtAllocator);

        // Only set an accountant if there is not one set yet.
        if (IVault(_vault).accountant() == address(0)) {
            _setAccountant(_vault);
        }

        address _asset = IVault(_vault).asset();

        // Add the vault config to the mapping.
        vaultConfig[_vault] = VaultConfig({
            asset: _asset,
            rollupID: _rollupID,
            debtAllocator: _debtAllocator,
            index: vaults.length
        });

        // Add the vault to the mapping.
        _assetToVault[_asset][_rollupID] = _vault;

        // Add the vault to the array.
        vaults.push(_vault);

        // Emit event.
        emit AddedNewVault(_vault, _debtAllocator, _rollupID);
    }

    /**
     * @notice Update a `_vault`s debt allocator.
     * @dev This will deploy a new allocator using the current
     *   allocator factory set.
     * @param _vault Address of the vault to update the allocator for.
     */
    function updateDebtAllocator(
        address _vault
    ) external virtual returns (address _newDebtAllocator) {
        _newDebtAllocator = _deployAllocator(_vault);
        updateDebtAllocator(_vault, _newDebtAllocator);
    }

    /**
     * @notice Update a `_vault`s debt allocator to a specified `_debtAllocator`.
     * @param _vault Address of the vault to update the allocator for.
     * @param _debtAllocator Address of the new debt allocator.
     */
    function updateDebtAllocator(
        address _vault,
        address _debtAllocator
    ) public virtual onlyPositionHolder(MANAGEMENT) {
        // Make sure the vault has been added to the role manager.
        require(vaultConfig[_vault].asset != address(0), "vault not added");

        // Remove the roles from the old allocator.
        _setRole(_vault, Position(vaultConfig[_vault].debtAllocator, 0));

        // Give the new debt allocator the relevant roles.
        _setRole(
            _vault,
            Position(_debtAllocator, _positions[DEBT_ALLOCATOR].roles)
        );

        // Update the vaults config.
        vaultConfig[_vault].debtAllocator = _debtAllocator;

        // Emit event.
        emit UpdateDebtAllocator(_vault, _debtAllocator);
    }

    /**
     * @notice Update a `_vault`s keeper to a specified `_keeper`.
     * @param _vault Address of the vault to update the keeper for.
     * @param _keeper Address of the new keeper.
     */
    function updateKeeper(
        address _vault,
        address _keeper
    ) external virtual onlyPositionHolder(MANAGEMENT) {
        // Make sure the vault has been added to the role manager.
        require(vaultConfig[_vault].asset != address(0), "vault not added");

        // Remove the roles from the old keeper if active.
        address defaultKeeper = getPositionHolder(KEEPER);
        if (
            _keeper != defaultKeeper && IVault(_vault).roles(defaultKeeper) != 0
        ) {
            _setRole(_vault, Position(defaultKeeper, 0));
        }

        // Give the new keeper the relevant roles.
        _setRole(_vault, Position(_keeper, _positions[KEEPER].roles));
    }

    /**
     * @notice Removes a vault from the RoleManager.
     * @dev This will NOT un-endorse the vault from the registry.
     * @param _vault Address of the vault to be removed.
     */
    function removeVault(
        address _vault
    ) external virtual onlyPositionHolder(MANAGEMENT) {
        // Get the vault specific config.
        VaultConfig memory config = vaultConfig[_vault];
        // Make sure the vault has been added to the role manager.
        require(config.asset != address(0), "vault not added");

        // Transfer the role manager position.
        IVault(_vault).transfer_role_manager(chad);

        // Address of the vault to replace it with.
        address vaultToMove = vaults[vaults.length - 1];

        // Move the last vault to the index of `_vault`
        vaults[config.index] = vaultToMove;
        vaultConfig[vaultToMove].index = config.index;

        // Remove the last item.
        vaults.pop();

        // Delete the vault from the mapping.
        delete _assetToVault[config.asset][config.rollupID];

        // Delete the config for `_vault`.
        delete vaultConfig[_vault];

        emit RemovedVault(_vault);
    }

    /**
     * @notice Removes a specific role(s) for a `_holder` from the `_vaults`.
     * @dev Can be used to remove one specific role or multiple.
     * @param _vaults Array of vaults to adjust.
     * @param _holder Address who's having a role removed.
     * @param _role The role or roles to remove from the `_holder`.
     */
    function removeRoles(
        address[] calldata _vaults,
        address _holder,
        uint256 _role
    ) external virtual onlyPositionHolder(CZAR) {
        address _vault;
        for (uint256 i = 0; i < _vaults.length; ++i) {
            _vault = _vaults[i];
            // Make sure the vault is added to this Role Manager.
            require(vaultConfig[_vault].asset != address(0), "vault not added");

            // Remove the role.
            IVault(_vault).remove_role(_holder, _role);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Setter function for updating a positions roles.
     * @param _position Identifier for the position.
     * @param _newRoles New roles for the position.
     */
    function setPositionRoles(
        bytes32 _position,
        uint256 _newRoles
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        // Cannot change the debt allocator or keeper roles since holder can be updated.
        require(
            _position != DEBT_ALLOCATOR && _position != KEEPER,
            "cannot update"
        );
        _positions[_position].roles = uint96(_newRoles);

        emit UpdatePositionRoles(_position, _newRoles);
    }

    /**
     * @notice Setter function for updating a positions holder.
     * @param _position Identifier for the position.
     * @param _newHolder New address for position.
     */
    function setPositionHolder(
        bytes32 _position,
        address _newHolder
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        require(_position != GOVERNATOR, "!two step flow");
        _positions[_position].holder = _newHolder;

        emit UpdatePositionHolder(_position, _newHolder);
    }

    /**
     * @notice Sets the default time until profits are fully unlocked for new vaults.
     * @param _newDefaultProfitMaxUnlock New value for defaultProfitMaxUnlock.
     */
    function setDefaultProfitMaxUnlock(
        uint256 _newDefaultProfitMaxUnlock
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        defaultProfitMaxUnlock = _newDefaultProfitMaxUnlock;

        emit UpdateDefaultProfitMaxUnlock(_newDefaultProfitMaxUnlock);
    }

    /**
     * @notice Accept the Governator role.
     * @dev Caller must be the Pending Governator.
     */
    function acceptGovernator()
        external
        virtual
        onlyPositionHolder(PENDING_GOVERNATOR)
    {
        // Set the Governator role to the caller.
        _positions[GOVERNATOR].holder = msg.sender;
        emit UpdatePositionHolder(GOVERNATOR, msg.sender);

        // Reset the Pending Governator.
        _positions[PENDING_GOVERNATOR].holder = address(0);
        emit UpdatePositionHolder(PENDING_GOVERNATOR, address(0));
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW METHODS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the name of this contract.
     */
    function name() external view virtual returns (string memory) {
        return string(abi.encodePacked("L1 Stake the Bridge Deployer"));
    }

    /**
     * @notice Get all vaults that this role manager controls..
     * @return The full array of vault addresses.
     */
    function getAllVaults() external view virtual returns (address[] memory) {
        return vaults;
    }

    /**
     * @notice Get the default vault for a specific asset and chain ID.
     * @dev This will return address(0) if one has not been added or deployed.
     * @param _asset The underlying asset used.
     * @return The default vault for the specified `_asset`.
     */
    function getVault(address _asset) public view virtual returns (address) {
        return getVault(_asset, DEFAULT_ID);
    }

    /**
     * @notice Get the vault for a specific asset and chain ID.
     * @dev This will return address(0) if one has not been added or deployed.
     *      A `_rollupID` of 0 will return the default vault.
     * @param _asset The underlying asset used.
     * @param _rollupID The rollup chain ID or 0 for the default version.
     * @return The vault for the specified `_asset` and `_rollupID`.
     */
    function getVault(
        address _asset,
        uint32 _rollupID
    ) public view virtual returns (address) {
        return _assetToVault[_asset][_rollupID];
    }

    /**
     * @notice Check if a vault is managed by this contract.
     * @dev This will check if the `asset` variable in the struct has been
     *   set for an easy external view check.
     *
     *   Does not check the vaults `role_manager` position since that can be set
     *   by anyone for a random vault.
     *
     * @param _vault Address of the vault to check.
     * @return . The vaults role manager status.
     */
    function isVaultsRoleManager(
        address _vault
    ) external view virtual returns (bool) {
        return vaultConfig[_vault].asset != address(0);
    }

    /**
     * @notice Get the debt allocator for a specific vault.
     * @dev Will return address(0) if the vault is not managed by this contract.
     * @param _vault Address of the vault.
     * @return . Address of the debt allocator if any.
     */
    function getDebtAllocator(
        address _vault
    ) external view virtual returns (address) {
        return vaultConfig[_vault].debtAllocator;
    }

    /**
     * @notice Get the address and roles given to a specific position.
     * @param _positionId The position identifier.
     * @return The address that holds that position.
     * @return The roles given to the specified position.
     */
    function getPosition(
        bytes32 _positionId
    ) public view virtual returns (address, uint256) {
        Position memory _position = _positions[_positionId];
        return (_position.holder, uint256(_position.roles));
    }

    /**
     * @notice Get the current address assigned to a specific position.
     * @param _positionId The position identifier.
     * @return The current address assigned to the specified position.
     */
    function getPositionHolder(
        bytes32 _positionId
    ) public view virtual returns (address) {
        return _positions[_positionId].holder;
    }

    /**
     * @notice Get the current roles given to a specific position ID.
     * @param _positionId The position identifier.
     * @return The current roles given to the specified position ID.
     */
    function getPositionRoles(
        bytes32 _positionId
    ) public view virtual returns (uint256) {
        return uint256(_positions[_positionId].roles);
    }

    /**
     * @notice Get the address assigned to the Czar.
     * @return The address assigned to the Czar.
     */
    function getCzar() external view virtual returns (address) {
        return getPositionHolder(CZAR);
    }

    /**
     * @notice Get the address assigned to the Governator.
     * @return The address assigned to the Governator.
     */
    function getGovernator() external view virtual returns (address) {
        return getPositionHolder(GOVERNATOR);
    }

    /**
     * @notice Get the address assigned to the Pending Governator.
     * @return The address assigned to the Pending Governator.
     */
    function getPendingGovernator() external view virtual returns (address) {
        return getPositionHolder(PENDING_GOVERNATOR);
    }

    /**
     * @notice Get the address assigned to Management.
     * @return The address assigned to Management.
     */
    function getManagement() external view virtual returns (address) {
        return getPositionHolder(MANAGEMENT);
    }

    /**
     * @notice Get the address assigned to the Emergency Admin position.
     * @return The address assigned to the Emergency Admin position.
     */
    function getEmergencyAdmin() external view virtual returns (address) {
        return getPositionHolder(EMERGENCY_ADMIN);
    }

    /**
     * @notice Get the address assigned to the Keeper position.
     * @return The address assigned to the Keeper position.
     */
    function getKeeper() external view virtual returns (address) {
        return getPositionHolder(KEEPER);
    }

    /**
     * @notice Get the address assigned to the accountant.
     * @return The address assigned to the accountant.
     */
    function getAccountant() external view virtual returns (address) {
        return getPositionHolder(ACCOUNTANT);
    }

    /**
     * @notice Get the address assigned to the Registry.
     * @return The address assigned to the Registry.
     */
    function getRegistry() external view virtual returns (address) {
        return getPositionHolder(REGISTRY);
    }

    /**
     * @notice Get the address assigned to be the debt allocator if any.
     * @return The address assigned to be the debt allocator if any.
     */
    function getDebtAllocator() external view virtual returns (address) {
        return getPositionHolder(DEBT_ALLOCATOR);
    }

    /**
     * @notice Get the address assigned to the allocator factory.
     * @return The address assigned to the allocator factory.
     */
    function getAllocatorFactory() external view virtual returns (address) {
        return getPositionHolder(ALLOCATOR_FACTORY);
    }

    /**
     * @notice Get the roles given to the Czar position.
     * @return The roles given to the Czar position.
     */
    function getCzarRoles() external view virtual returns (uint256) {
        return getPositionRoles(CZAR);
    }

    /**
     * @notice Get the roles given to the Management position.
     * @return The roles given to the Management position.
     */
    function getManagementRoles() external view virtual returns (uint256) {
        return getPositionRoles(MANAGEMENT);
    }

    /**
     * @notice Get the roles given to the Emergency Admin position.
     * @return The roles given to the Emergency Admin position.
     */
    function getEmergencyAdminRoles() external view virtual returns (uint256) {
        return getPositionRoles(EMERGENCY_ADMIN);
    }

    /**
     * @notice Get the roles given to the Keeper position.
     * @return The roles given to the Keeper position.
     */
    function getKeeperRoles() external view virtual returns (uint256) {
        return getPositionRoles(KEEPER);
    }

    /**
     * @notice Get the roles given to the debt allocators.
     * @return The roles given to the debt allocators.
     */
    function getDebtAllocatorRoles() external view virtual returns (uint256) {
        return getPositionRoles(DEBT_ALLOCATOR);
    }
}

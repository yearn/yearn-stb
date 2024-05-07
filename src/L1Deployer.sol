// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Proxy} from "@zkevm-stb/Proxy.sol";
import {RoleManager} from "./RoleManager.sol";
import {L1YearnEscrow} from "./L1YearnEscrow.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "./interfaces/Polygon/IPolygonRollupManager.sol";

/// @title Polygon CDK Stake the Bridge L1 Deployer.
contract L1Deployer is RoleManager {
    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed escrowManager
    );

    event UpdateEscrowManager(
        uint32 indexed rollupID,
        address indexed escrowManager
    );

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    struct ChainConfig {
        IPolygonRollupContract rollupContract;
        address escrowManager;
        mapping(address => address) escrows; // asset => escrow contract
    }

    /// @notice Only allow either governance or the position holder to call.
    modifier onlyRollupAdmin(uint32 _rollupID) {
        _isRollupAdmin(_rollupID);
        _;
    }

    /// @notice Check if the msg sender is governance or the specified position holder.
    function _isRollupAdmin(uint32 _rollupID) internal view virtual {
        require(
            msg.sender == _chainConfig[_rollupID].rollupContract.admin(),
            "!admin"
        );
    }

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant L2_FACTORY = keccak256("L2 Factory");

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLE'S
    //////////////////////////////////////////////////////////////*/

    IPolygonRollupManager public immutable rollupManager;

    /*//////////////////////////////////////////////////////////////
                           STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of chain ID to the rollup config.
    mapping(uint32 => ChainConfig) internal _chainConfig;

    constructor(
        address _governator,
        address _czar,
        address _management,
        address _emergencyAdmin,
        address _keeper,
        address _registry,
        address _allocatorFactory,
        address _polygonZkEVMBridge,
        address _l2Deployer,
        address _escrowImplementation
    )
        RoleManager(
            _governator,
            _czar,
            _management,
            _emergencyAdmin,
            _keeper,
            _registry,
            _allocatorFactory,
            _polygonZkEVMBridge,
            _l2Deployer,
            _escrowImplementation
        )
    {
        rollupManager = IPolygonRollupManager(
            polygonZkEVMBridge.polygonRollupManager()
        );
    }

    /*//////////////////////////////////////////////////////////////
                           ESCROW CREATION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deploy a new L1 escrow contract for a specific rollup.
     * @dev This will also trigger the L2 deployer to deploy deploy all needed
     *   contracts for the new bridged asset.
     *
     * This will register the rollup internally if not yet done.
     *
     * This will deploy a new Yearn vault and do the full setup if a default version
     * is not yet deployed.
     *
     * @param _rollupID The rollups ID
     * @param _asset The asset to bridge to the rollup.
     * @return _l1Escrow The address of the rollup specific l1 Escrow.
     * @return _vault The Yearn vault the escrow will deposit into.
     */
    function newEscrow(
        uint32 _rollupID,
        address _asset
    ) external virtual returns (address _l1Escrow, address _vault) {
        // Register rollup if not already done. Verifies its a valid rollup ID.
        if (getRollupContract(_rollupID) == address(0)) {
            _registerRollup(_rollupID, address(0));
        }

        // Verify that an escrow is not already deployed for that chain.
        _l1Escrow = getEscrow(_rollupID, _asset);
        if (_l1Escrow != address(0)) revert AlreadyDeployed(_l1Escrow);

        // Check if there is a current default vault.
        _vault = getVault(_asset);

        // If not, deploy one and do full setup
        if (_vault == address(0)) {
            _vault = _newVault(ORIGIN_NETWORK_ID, _asset);
        }

        // Deploy L1 Escrow.
        _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
    }

    /*//////////////////////////////////////////////////////////////
                           ROLLUP MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Register a rollup with this deployer contract.
     * @dev Only a rollups Admin can set the `_escrowManager`
     * @param _rollupID ID for the rollup to register
     * @param _escrowManager Address to set as the L1 Manager.
     */
    function registerRollup(
        uint32 _rollupID,
        address _escrowManager
    ) external virtual {
        require(getRollupContract(_rollupID) == address(0), "registered");
        _registerRollup(_rollupID, _escrowManager);
    }

    /**
     * @dev Registers a new rollup with the Deployer.
     *   This is called either manually or during the first {newEscrow} call.
     */
    function _registerRollup(
        uint32 _rollupID,
        address _escrowManager
    ) internal virtual {
        IPolygonRollupContract _rollupContract = rollupManager
            .rollupIDToRollupData(_rollupID)
            .rollupContract;

        // Checks the rollup ID is valid
        address admin = _rollupContract.admin();
        // If the caller is not the rollup Admin.
        if (
            msg.sender != _rollupContract.admin() ||
            _escrowManager == address(0)
        ) {
            // Default the manager to be the admin
            _escrowManager = admin;
        }

        _chainConfig[_rollupID].rollupContract = _rollupContract;
        _chainConfig[_rollupID].escrowManager = _escrowManager;

        emit RegisteredNewRollup(
            _rollupID,
            address(_rollupContract),
            _escrowManager
        );
    }

    /**
     * @notice Allows the Rollup Admin to change the L1 Manager.
     * @param _rollupID ID for the rollup.
     * @param _escrowManager New address to set as l1Manager in new escrows.
     */
    function updateEscrowManager(
        uint32 _rollupID,
        address _escrowManager
    ) external virtual onlyRollupAdmin(_rollupID) {
        require(_escrowManager != address(0), "ZERO ADDRESS");
        _chainConfig[_rollupID].escrowManager = _escrowManager;

        emit UpdateEscrowManager(_rollupID, _escrowManager);
    }

    /**
     * @notice Must be called by the L2's Admin in order to deploy the L2 Deployer contract.
     */
    function deployL2Deployer(
        uint32 _rollupID,
        address _l2Admin,
        address _l2RiskManager,
        address _l2EscrowManager
    ) external {
        // Register rollup if not already done. Verifies its a valid rollup ID.
        if (getRollupContract(_rollupID) == address(0)) {
            _registerRollup(_rollupID, address(0));
        }

        // Can only be called by Admin
        _isRollupAdmin(_rollupID);

        require(_l2Admin != address(0), "ZERO ADDRESS");

        address _l2Factory = getPositionHolder(L2_FACTORY);

        polygonZkEVMBridge.bridgeMessage(
            _rollupID,
            _l2Factory,
            true,
            abi.encode(_l2Admin, _l2RiskManager, _l2EscrowManager)
        );
    }

    /*//////////////////////////////////////////////////////////////
                        CUSTOM VAULTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new custom vault and escrow for a specific asset on the specified rollup.
     * @param _rollupID The ID of the rollup.
     * @param _asset The address of the asset for which the vault and escrow are created.
     * @return _l1Escrow The address of the L1 escrow.
     * @return _vault The address of the newly created vault.
     */
    function newCustomVault(
        uint32 _rollupID,
        address _asset
    )
        external
        virtual
        onlyRollupAdmin(_rollupID)
        returns (address _l1Escrow, address _vault)
    {
        _vault = _newVault(_rollupID, _asset);
        _l1Escrow = _newCustomVault(_rollupID, _asset, _vault);
    }

    /**
     * @notice Adds a new custom vault for a specific asset on the specified rollup.
     * @param _rollupID The ID of the rollup.
     * @param _asset The address of the asset for which the vault is created.
     * @param _vault The address of the vault.
     * @return _l1Escrow The address of the L1 escrow.
     */
    function newCustomVault(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) external virtual onlyRollupAdmin(_rollupID) returns (address _l1Escrow) {
        // If the vault has not been registered yet.
        if (!isVaultsRoleManager(_vault)) {
            _addNewVault(_rollupID, _vault);
        }
        _l1Escrow = _newCustomVault(_rollupID, _asset, _vault);
    }

    /**
     * @dev Deploys an L1 Escrow for a custom vault if one does not exist.
     *  Will store all relevant information as well.
     */
    function _newCustomVault(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) internal virtual returns (address _l1Escrow) {
        _l1Escrow = getEscrow(_rollupID, _asset);

        if (_l1Escrow == address(0)) {
            _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        ESCROW CREATION
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deploys a new L1 Escrow and send a message to the bridge to
     *   tell the L2 deployer to deploy the needed contract on the L2
     */
    function _deployL1Escrow(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) internal returns (address _l1Escrow) {
        ChainConfig storage chainConfig_ = _chainConfig[_rollupID];

        // Get the init data for the proxy implementation
        bytes memory data = abi.encodeCall(
            L1YearnEscrow.initialize,
            (
                chainConfig_.rollupContract.admin(),
                chainConfig_.escrowManager,
                address(polygonZkEVMBridge),
                getL2EscrowAddress(_asset),
                _rollupID,
                _asset,
                getL2TokenAddress(_asset),
                _vault
            )
        );

        // Cache to double check we deploy to the right address.
        address expectedL1Escrow = getL1EscrowAddress(_asset, _rollupID);

        // Deploy the new escrow and initialize
        _l1Escrow = _create3Deploy(
            keccak256(abi.encodePacked(bytes("L1Escrow:"), _asset, _rollupID)),
            getPositionHolder(ESCROW_IMPLEMENTATION),
            data
        );

        // Make sure we got the right address.
        require(_l1Escrow == expectedL1Escrow, "wrong address");

        // Set the mapping
        chainConfig_.escrows[_asset] = _l1Escrow;

        // Send Message to Bridge for L2
        polygonZkEVMBridge.bridgeMessage(
            _rollupID,
            getPositionHolder(L2_DEPLOYER),
            true,
            abi.encode(
                BridgeData({
                    l1Token: _asset,
                    l1Escrow: _l1Escrow,
                    name: ERC20(_asset).name(),
                    symbol: ERC20(_asset).symbol()
                })
            )
        );

        emit NewL1Escrow(_rollupID, _l1Escrow);
    }

    /*//////////////////////////////////////////////////////////////
                        GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the address of the rollup contract associated with the specified rollup ID.
     * @param _rollupID The ID of the rollup.
     * @return The address of the rollup contract.
     */
    function getRollupContract(uint32 _rollupID) public view returns (address) {
        return address(_chainConfig[_rollupID].rollupContract);
    }

    /**
     * @dev Returns the address of the escrow manager associated with the specified rollup.
     * @param _rollupID The ID of the rollup.
     * @return The address of the escrow manager.
     */
    function getEscrowManager(uint32 _rollupID) public view returns (address) {
        return _chainConfig[_rollupID].escrowManager;
    }

    /**
     * @notice Get the L1 Escrow for a specific asset and rollup ID.
     * @dev This will return address(0) if one has not been added or deployed.
     * @param _rollupID The ID of the rollup.
     * @param _asset The underlying asset used.
     * @return The Escrow for the specified `_asset` and `_rollupID`.
     */
    function getEscrow(
        uint32 _rollupID,
        address _asset
    ) public view virtual returns (address) {
        return _chainConfig[_rollupID].escrows[_asset];
    }
}

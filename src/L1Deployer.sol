// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {RoleManager} from "./RoleManager.sol";
import {DeployerBase} from "./DeployerBase.sol";
import {L1YearnEscrow} from "./L1YearnEscrow.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IPolygonZkEVMBridge} from "./interfaces/Polygon/IPolygonZkEVMBridge.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "./interfaces/Polygon/IPolygonRollupManager.sol";

/// @title Polygon CDK Stake the Bridge L1 Deployer.
contract L1Deployer is DeployerBase {
    /// @notice Revert message for when a contract has already been deployed.
    error AlreadyDeployed(address _contract);

    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed escrowManager,
        address l2Deployer
    );

    event UpdateEscrowManager(
        uint32 indexed rollupID,
        address indexed escrowManager
    );

    event UpdateL2Deployer(uint32 indexed rollupID, address indexed l2Deployer);

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    struct ChainConfig {
        IPolygonRollupContract rollupContract;
        address l2Deployer;
        address escrowManager;
        mapping(address => address) escrows; // asset => escrow contract
    }

    /// @notice Only allow either governance or the position holder to call.
    modifier onlyRollupAdmin(uint32 _rollupID) {
        _isRollupAdmin(_rollupID);
        _;
    }

    /// @notice Assure that the Rollup has been registered.
    modifier isRegistered(uint32 _rollupID) {
        _isRegistered(_rollupID);
        _;
    }

    /// @notice Check if the msg sender is governance or the specified position holder.
    function _isRollupAdmin(uint32 _rollupID) internal view virtual {
        require(
            msg.sender == _chainConfig[_rollupID].rollupContract.admin(),
            "!admin"
        );
    }

    /// @notice Check if the Rollup ID has been registered.
    function _isRegistered(uint32 _rollupID) internal view virtual {
        require(getRollupContract(_rollupID) != address(0), "!registered");
    }

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLE'S
    //////////////////////////////////////////////////////////////*/

    /// @notice Yearn STB Role Manager.
    RoleManager public immutable roleManager;

    /// @notice Polygon CDK Rollup Manager.
    IPolygonRollupManager public immutable rollupManager;

    /*//////////////////////////////////////////////////////////////
                           STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of chain ID to the rollup config.
    mapping(uint32 => ChainConfig) internal _chainConfig;

    constructor(
        address _bridgeAddress,
        address _roleManager
    )
        DeployerBase(
            _bridgeAddress,
            address(this),
            address(new L1YearnEscrow())
        )
    {
        roleManager = RoleManager(_roleManager);

        rollupManager = IPolygonRollupManager(
            IPolygonZkEVMBridge(bridgeAddress).polygonRollupManager()
        );
    }

    /**
     * @notice Get the name of this contract.
     */
    function name() external view virtual returns (string memory) {
        return "L1 Stake the Bridge Deployer";
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
    )
        external
        virtual
        isRegistered(_rollupID)
        returns (address _l1Escrow, address _vault)
    {
        // Verify that an escrow is not already deployed for that chain.
        _l1Escrow = getEscrow(_rollupID, _asset);
        if (_l1Escrow != address(0)) revert AlreadyDeployed(_l1Escrow);

        // Check if there is a current default vault.
        _vault = roleManager.getVault(_asset);

        // If not, deploy one and do full setup
        if (_vault == address(0)) {
            _vault = roleManager.newVault(ORIGIN_NETWORK_ID, _asset);
        }

        // Deploy L1 Escrow.
        _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
    }

    /*//////////////////////////////////////////////////////////////
                           ROLLUP MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function testRegisterRollup(
        uint32 _rollupID,
        address _l1EscrowManager,
        address _l2Deployer
    ) external {}

    /**
     * @notice Register a rollup with this deployer contract.
     * @dev Only a rollups Admin can set the `_l1EscrowManager`
     * @param _rollupID ID for the rollup to register
     * @param _l1EscrowManager Address to set as the L1 Manager.
     * @param _l2Deployer Rollup Specific L2 Deployer
     */
    function registerRollup(
        uint32 _rollupID,
        address _l1EscrowManager,
        address _l2Deployer
    ) external virtual {
        require(getRollupContract(_rollupID) == address(0), "registered");
        require(_l1EscrowManager != address(0), "ZERO ADDRESS");
        require(_l2Deployer != address(0), "ZERO ADDRESS");

        IPolygonRollupContract _rollupContract = rollupManager
            .rollupIDToRollupData(_rollupID)
            .rollupContract;

        // Checks the rollup ID is valid and the caller is admin.
        require(msg.sender == _rollupContract.admin(), "!admin");

        _chainConfig[_rollupID].rollupContract = _rollupContract;
        _chainConfig[_rollupID].escrowManager = _l1EscrowManager;
        _chainConfig[_rollupID].l2Deployer = _l2Deployer;

        emit RegisteredNewRollup(
            _rollupID,
            address(_rollupContract),
            _l1EscrowManager,
            _l2Deployer
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
    function updateL2Deployer(
        uint32 _rollupID,
        address _l2Deployer
    ) external virtual onlyRollupAdmin(_rollupID) {
        require(_l2Deployer != address(0), "ZERO ADDRESS");
        _chainConfig[_rollupID].l2Deployer = _l2Deployer;

        emit UpdateL2Deployer(_rollupID, _l2Deployer);
    }

    /*//////////////////////////////////////////////////////////////
                        CUSTOM VAULTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new custom vault and escrow for a specific asset on the specified rollup.
     * @dev If the L1 escrow already exists the Rollup admin
     *  will need to update the vault manually on the escrow.
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
        _vault = roleManager.newVault(_rollupID, _asset);
        // Deploy an L1 escrow if it does not already exist.
        _l1Escrow = getEscrow(_rollupID, _asset);
        if (_l1Escrow == address(0)) {
            _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
        }
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
        // Make sure the vault has been registered.
        require(roleManager.isVaultsRoleManager(_vault), "!role manager");
        _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
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
                bridgeAddress,
                getL2EscrowAddress(_rollupID, _asset),
                _rollupID,
                _asset,
                getL2TokenAddress(_rollupID, _asset),
                _vault
            )
        );

        // Cache to double check we deploy to the right address.
        address expectedL1Escrow = getL1EscrowAddress(_rollupID, _asset);

        // Deploy the new escrow and initialize
        _l1Escrow = _create3Deploy(
            keccak256(abi.encodePacked(bytes("L1Escrow:"), _rollupID, _asset)),
            getPositionHolder(ESCROW_IMPLEMENTATION),
            data
        );

        // Make sure we got the right address.
        require(_l1Escrow == expectedL1Escrow, "wrong address");

        // Set the mapping
        chainConfig_.escrows[_asset] = _l1Escrow;

        // Send Message to Bridge for L2
        IPolygonZkEVMBridge(bridgeAddress).bridgeMessage(
            _rollupID,
            chainConfig_.l2Deployer,
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
     * @notice Get the :2 Deployer for a specific rollup.
     * @param _rollupID Rollup ID for the L2.
     * @return The L2 Deployer address.
     */
    function getL2Deployer(
        uint32 _rollupID
    ) public view virtual override returns (address) {
        return _chainConfig[_rollupID].l2Deployer;
    }

    /**
     * @dev Returns the address of the rollup contract associated with the specified rollup ID.
     * @param _rollupID The ID of the rollup.
     * @return The address of the rollup contract.
     */
    function getRollupContract(
        uint32 _rollupID
    ) public view virtual returns (address) {
        return address(_chainConfig[_rollupID].rollupContract);
    }

    /**
     * @dev Returns the address of the escrow manager associated with the specified rollup.
     * @param _rollupID The ID of the rollup.
     * @return The address of the escrow manager.
     */
    function getEscrowManager(
        uint32 _rollupID
    ) external view virtual returns (address) {
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

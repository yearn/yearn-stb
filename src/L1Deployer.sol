// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Proxy} from "@zkevm-stb/Proxy.sol";
import {RoleManager} from "./RoleManager.sol";
import {DeployerBase} from "./DeployerBase.sol";
import {L1YearnEscrow} from "./L1YearnEscrow.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "./interfaces/Polygon/IPolygonRollupManager.sol";

// TODO:
//  getters for custom position holders
//  create 3 factory
// External create3 Address getters
//
/// Governance Structure:
// 1. GOVERNATOR Can change the Holders, Impl and addresses (Rare) 2/3 meta multisig (No Roles)
// 2. CZAR/DADDY Sets strategies All Roles
// 3. Management/SMS Day to Day Ops

/// @title PolyYearn Stake the Bridge Role Manager.
contract L1Deployer is DeployerBase, RoleManager {
    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed manager
    );

    event UpdateRollupManager(uint32 indexed rollupID, address indexed manager);

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    struct ChainConfig {
        IPolygonRollupContract rollupContract;
        address manager;
        mapping(address => address) escrows;
    }

    /// @notice Only allow either governance or the position holder to call.
    modifier onlyRollupAdmin(uint32 _rollupID) {
        _isRollupAdmin(_rollupID);
        _;
    }

    /// @notice Check if the msg sender is governance or the specified position holder.
    function _isRollupAdmin(uint32 _rollupID) internal view virtual {
        require(
            msg.sender == chainConfig[_rollupID].rollupContract.admin(),
            "!admin"
        );
    }

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    IPolygonRollupManager public immutable rollupManager;

    /*//////////////////////////////////////////////////////////////
                           STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of chain ID to the rollup config.
    mapping(uint32 => ChainConfig) public chainConfig;

    constructor(
        address _governator,
        address _czar,
        address _management,
        address _emergencyAdmin,
        address _keeper,
        address _registry,
        address _allocatorFactory,
        address _polygonZkEVMBridge,
        address _escrowImplementation
    )
        DeployerBase(_polygonZkEVMBridge)
        RoleManager(
            _governator,
            _czar,
            _management,
            _emergencyAdmin,
            _keeper,
            _registry,
            _allocatorFactory
        )
    {
        rollupManager = IPolygonRollupManager(
            polygonZkEVMBridge.polygonRollupManager()
        );
        _positions[ESCROW_IMPLEMENTATION].holder = _escrowImplementation;
    }

    function registerRollup(
        uint32 _rollupID,
        address _l1Manager
    ) external virtual {
        ChainConfig storage _chainConfig = chainConfig[_rollupID];
        require(
            address(_chainConfig.rollupContract) == address(0),
            "registered"
        );
        require(_l1Manager != address(0), "ZERO ADDRESS");

        IPolygonRollupContract _rollupContract = rollupManager
            .rollupIDToRollupData(_rollupID)
            .rollupContract;
        // Checks the rollup ID is valid and the caller is the rollup Admin.
        require(msg.sender == _rollupContract.admin(), "!admin");

        _chainConfig.rollupContract = _rollupContract;
        _chainConfig.manager = _l1Manager;

        emit RegisteredNewRollup(
            _rollupID,
            address(_rollupContract),
            _l1Manager
        );
    }

    function updateRollupManager(
        uint32 _rollupID,
        address _l1Manager
    ) external virtual onlyRollupAdmin(_rollupID) {
        require(_l1Manager != address(0), "ZERO ADDRESS");
        chainConfig[_rollupID].manager = _l1Manager;

        emit UpdateRollupManager(_rollupID, _l1Manager);
    }

    /*//////////////////////////////////////////////////////////////
                           ESCROW CREATION
    //////////////////////////////////////////////////////////////*/

    function newAsset(
        uint32 _rollupID,
        address _asset
    ) external virtual returns (address _vault, address _l1Escrow) {
        // Verify the rollup Id is valid.
        require(
            address(chainConfig[_rollupID].rollupContract) != address(0),
            "rollup not registered"
        );

        // Verify that the vault is not already set for that chain.
        _l1Escrow = getEscrow(_rollupID, _asset);
        if (_l1Escrow != address(0)) revert AlreadyDeployed(_l1Escrow);

        // Check if there is a current default vault.
        _vault = getVault(_asset);

        // If not, deploy one and do full setup
        if (_vault == address(0)) {
            _vault = _deployDefaultVault(_asset);
        }

        // Deploy L1 Escrow.
        _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
    }

    function newCustomAsset(
        uint32 _rollupID,
        address _asset
    ) external virtual onlyRollupAdmin(_rollupID) returns (address _vault) {
        string memory _rollupIDString = Strings.toString(_rollupID);

        // Name is "{SYMBOL}-STB-{rollupID} yVault"
        string memory _name = string(
            abi.encodePacked(
                ERC20(_asset).symbol(),
                "-STB-",
                _rollupIDString,
                " yVault"
            )
        );
        // Symbol is "stb{SYMBOL}-{rollupID}".
        string memory _symbol = string(
            abi.encodePacked(
                "stb",
                ERC20(_asset).symbol(),
                "-",
                _rollupIDString
            )
        );

        _vault = _newVault(
            _asset,
            _name,
            _symbol,
            _rollupID,
            2 ** 256 - 1,
            defaultProfitMaxUnlock
        );

        // Custom Roles???
        _newCustomAsset(_rollupID, _asset, _vault);
    }

    function newCustomAsset(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) external virtual onlyRollupAdmin(_rollupID) {
        _addNewVault(_rollupID, _vault);
        _newCustomAsset(_rollupID, _asset, _vault);
    }

    function _newCustomAsset(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) internal virtual {
        address _l1Escrow = getEscrow(_rollupID, _asset);

        if (_l1Escrow == address(0)) {
            _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault);
        }

        _assetToVault[_asset][_rollupID] = _vault;
    }

    /*//////////////////////////////////////////////////////////////
                           VAULT CREATION
    //////////////////////////////////////////////////////////////*/

    function _deployDefaultVault(
        address _asset
    ) internal virtual returns (address) {
        // Name is "{SYMBOL}-STB yVault"
        string memory _name = string(
            abi.encodePacked(ERC20(_asset).symbol(), "-STB yVault")
        );
        // Symbol is "stb{SYMBOL}".
        string memory _symbol = string(
            abi.encodePacked("stb", ERC20(_asset).symbol())
        );

        return
            _newVault(
                _asset,
                _name,
                _symbol,
                DEFAULT_ID,
                2 ** 256 - 1,
                defaultProfitMaxUnlock
            );
    }

    function _deployL1Escrow(
        uint32 _rollupID,
        address _asset,
        address _vault
    ) internal returns (address _l1Escrow) {
        ChainConfig storage _chainConfig = chainConfig[_rollupID];

        bytes memory data = abi.encodeCall(
            L1YearnEscrow.initialize,
            (
                _chainConfig.rollupContract.admin(),
                _chainConfig.manager,
                address(polygonZkEVMBridge),
                getL2EscrowAddress(_asset),
                _rollupID,
                _asset,
                getL2TokenAddress(_asset),
                _vault
            )
        );

        _l1Escrow = _create3Deploy(
            keccak256(abi.encodePacked(bytes("L1Escrow:"), _asset)),
            getPositionHolder(ESCROW_IMPLEMENTATION),
            data
        );

        // Make sure we got the right address.
        require(_l1Escrow == getL1EscrowAddress(_asset), "wrong address");

        // Set the mapping
        _chainConfig.escrows[_asset] = _l1Escrow;

        // Send Message to Bridge for L2
        // TODO: Will L2 Deployer be the same each chain?
        polygonZkEVMBridge.bridgeMessage(
            _rollupID,
            getPositionHolder(L2_DEPLOYER),
            true,
            abi.encode(
                _asset,
                _l1Escrow,
                ERC20(_asset).name(),
                ERC20(_asset).symbol()
            )
        );

        emit NewL1Escrow(_rollupID, _l1Escrow);
    }

    /**
     * @notice Get the L1 Escrow for a specific asset and chain ID.
     * @dev This will return address(0) if one has not been added or deployed.
     * @param _rollupID The rollup chain ID.
     * @param _asset The underlying asset used.
     * @return The Escrow for the specified `_asset` and `_rollupID`.
     */
    function getEscrow(
        uint32 _rollupID,
        address _asset
    ) public view virtual returns (address) {
        return chainConfig[_rollupID].escrows[_asset];
    }

    function getL1Deployer() public view virtual override returns (address) {
        return address(this);
    }

    function getL2Deployer() public view virtual override returns (address) {
        return getPositionHolder(L2_DEPLOYER);
    }

    function getEscrowImplementation()
        external
        view
        virtual
        override
        returns (address)
    {
        return getPositionHolder(ESCROW_IMPLEMENTATION);
    }
}

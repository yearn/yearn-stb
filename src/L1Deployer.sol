// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L1YearnEscrow} from "./L1YearnEscrow.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IPolygonZkEVMBridge} from "@zkevm-stb/interfaces/IPolygonZkEVMBridge.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "./interfaces/Polygon/IPolygonRollupManager.sol";

import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";
import {Proxy} from "@zkevm-stb/Proxy.sol";

import {RoleManager} from "./RoleManager.sol";

// TODO:
//  1. Deposit Limits/module
//  create 3 factory
// External create3 Address getters

/// Governace Structure:
// 1. GOVERNATOR Can change the Holders, Impl and addresses (Rare) 2/3 meta multisig (No Roles)
// 2. CZAR/DADDY Sets strategies All Roles
// 3. Management/SMS Day to Day Ops

/// @title PolyYearn Stake the Bridge Role Manager.
contract L1Deployer is RoleManager {
    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed manager
    );

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    struct ChainConfig {
        IPolygonRollupContract rollupContract;
        address manager;
        mapping(address => address) escrows;
    }

    /// @notice Only allow either governance or the position holder to call.
    modifier onlyChainAdmin(uint32 _rollupID) {
        _isChainAdmin(_rollupID);
        _;
    }

    /// @notice Check if the msg sender is governance or the specified position holder.
    function _isChainAdmin(uint32 _rollupID) internal view virtual {
        require(
            msg.sender == chainConfig[_rollupID].rollupContract.admin(),
            "!admin"
        );
    }

    ICREATE3Factory internal create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant ESCROW_IMPLEMENTATION =
        keccak256("Escrow Implementation");
    bytes32 public constant L2_DEPLOYER = keccak256("L2 Deployer");

    uint256 public immutable originalID;

    address public immutable bridgeAddress;

    address public immutable rollupManager;

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
        address _rollupManager,
        address _escrowImplementation
    )
        RoleManager(
            _governator,
            _czar,
            _management,
            _emergencyAdmin,
            _keeper,
            _registry
        )
    {
        originalID = block.chainid;
        bridgeAddress = IPolygonRollupManager(_rollupManager).bridgeAddress();
        rollupManager = _rollupManager;

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

        IPolygonRollupContract _rollupContract = IPolygonRollupManager(
            rollupManager
        ).rollupIDToRollupData(_rollupID).rollupContract;
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

    /*//////////////////////////////////////////////////////////////
                           ESCROW CREATION
    //////////////////////////////////////////////////////////////*/

    function newAsset(
        uint32 _rollupID,
        address _asset
    ) external returns (address, address) {
        // Verify the rollup Id is valid.
        require(
            address(chainConfig[_rollupID].rollupContract) != address(0),
            "rollup not registered"
        );
        return _newAsset(_rollupID, _asset, 0);
    }

    function newAsset(
        uint32 _rollupID,
        address _asset,
        uint256 _minimumBuffer
    ) external onlyChainAdmin(_rollupID) returns (address, address) {
        // Modifier passing implies a valid rollup ID.
        return _newAsset(_rollupID, _asset, _minimumBuffer);
    }

    function _newAsset(
        uint32 _rollupID,
        address _asset,
        uint256 _minimumBuffer
    ) internal virtual returns (address _vault, address _l1Escrow) {
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
        _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault, _minimumBuffer);
    }

    function newCustomAsset(
        uint32 _rollupID,
        address _asset
    ) external virtual onlyChainAdmin(_rollupID) returns (address _vault) {
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
    ) external virtual onlyChainAdmin(_rollupID) {
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
            _l1Escrow = _deployL1Escrow(_rollupID, _asset, _vault, 0);
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
        address _vault,
        uint256 _minimumBuffer
    ) internal returns (address _l1Escrow) {
        ChainConfig storage _chainConfig = chainConfig[_rollupID];

        bytes memory symbol = bytes(ERC20(_asset).symbol());

        bytes memory data = abi.encodeWithSelector(
            L1YearnEscrow.initialize.selector,
            _chainConfig.rollupContract.admin(),
            _chainConfig.manager,
            bridgeAddress,
            _getL2EscrowAddress(symbol),
            _rollupID,
            _asset,
            _getL2TokenAddress(symbol),
            _vault,
            _minimumBuffer
        );

        bytes memory creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(address(getPositionHolder(ESCROW_IMPLEMENTATION)), data)
        );

        _l1Escrow = create3Factory.deploy(
            keccak256(abi.encodePacked(bytes("L1Escrow:"), symbol)),
            creationCode
        );

        // Make sure we got the right address.
        require(_l1Escrow == _getL1EscrowAddress(symbol), "wrong address");

        // Set the mapping
        _chainConfig.escrows[_asset] = _l1Escrow;

        // Send Message to Bridge for L2
        // TODO: Will L2 Deployer be the same each chain?
        IPolygonZkEVMBridge(bridgeAddress).bridgeMessage(
            _rollupID,
            getPositionHolder(L2_DEPLOYER),
            false,
            abi.encode(_asset, _l1Escrow)
        );

        emit NewL1Escrow(_rollupID, _l1Escrow);
    }

    function _getL1EscrowAddress(
        bytes memory _symbol
    ) internal returns (address) {
        return
            create3Factory.getDeployed(
                address(this),
                keccak256(abi.encodePacked(bytes("L1Escrow:"), _symbol))
            );
    }

    // Address will be the L2 deployer
    function _getL2EscrowAddress(
        bytes memory _symbol
    ) internal returns (address) {
        return
            create3Factory.getDeployed(
                getPositionHolder(L2_DEPLOYER),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _symbol))
            );
    }

    function _getL2TokenAddress(
        bytes memory _symbol
    ) internal returns (address) {
        return
            create3Factory.getDeployed(
                getPositionHolder(L2_DEPLOYER),
                keccak256(abi.encode(bytes("L2Token:"), _symbol))
            );
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
}

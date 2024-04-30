// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Positions} from "./Positions.sol";
import {Proxy} from "@zkevm-stb/Proxy.sol";
import {CREATE3} from "./libraries/CREATE3.sol";
import {IPolygonZkEVMBridge} from "./interfaces/Polygon/IPolygonZkEVMBridge.sol";

/**
 * @title DeployerBase
 * @notice To be inherited by the L1 and L2 Deployer's for common functionality.
 */
contract DeployerBase is Positions {
    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant L1_DEPLOYER = keccak256("L1 Deployer");
    bytes32 public constant L2_DEPLOYER = keccak256("L2 Deployer");
    bytes32 public constant ESCROW_IMPLEMENTATION =
        keccak256("Escrow Implementation");

    /// @notice Address of the PolygonZkEVMBridge contract
    IPolygonZkEVMBridge public immutable polygonZkEVMBridge;

    constructor(
        address _polygonZkEVMBridge,
        address _l1Deployer,
        address _l2Deployer,
        address _escrowImplementation
    ) {
        polygonZkEVMBridge = IPolygonZkEVMBridge(_polygonZkEVMBridge);
        _setPositionHolder(L1_DEPLOYER, _l1Deployer);
        _setPositionHolder(L2_DEPLOYER, _l2Deployer);
        _setPositionHolder(ESCROW_IMPLEMENTATION, _escrowImplementation);
    }

    /**
     * @notice Get expected L2 token address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L2 token contract
     */
    function getL2TokenAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            _getDeployed(
                getPositionHolder(L2_DEPLOYER),
                keccak256(abi.encodePacked(bytes("L2Token:"), _l1TokenAddress))
            );
    }

    /**
     * @notice Get expected L1 escrow address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L1 escrow contract
     */
    function getL1EscrowAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            _getDeployed(
                getPositionHolder(L1_DEPLOYER),
                keccak256(abi.encodePacked(bytes("L1Escrow:"), _l1TokenAddress))
            );
    }

    /**
     * @notice Get expected L2 escrow address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L2 escrow contract
     */
    function getL2EscrowAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            _getDeployed(
                getPositionHolder(L2_DEPLOYER),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _l1TokenAddress))
            );
    }

    /**
     * @notice Get expected L2 converter address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L2 converter contract
     */
    function getL2ConverterAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            _getDeployed(
                getPositionHolder(L2_DEPLOYER),
                keccak256(
                    abi.encodePacked(
                        bytes("L2TokenConverter:"),
                        _l1TokenAddress
                    )
                )
            );
    }

    /**
     * @dev Get the expected address based on the deployer and salt.
     */
    function _getDeployed(
        address deployer,
        bytes32 salt
    ) internal view virtual returns (address) {
        return CREATE3.getDeployed(deployer, salt);
    }

    /**
     * @notice Deploy a contract using CREATE3
     * @param _salt Salt value for contract deployment
     * @param _implementation Address of the contract implementation
     * @param _initData Data to initialize the contract with
     * @return Address of the deployed contract
     */
    function _create3Deploy(
        bytes32 _salt,
        address _implementation,
        bytes memory _initData
    ) internal returns (address) {
        bytes memory _creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(_implementation, _initData)
        );

        return CREATE3.deploy(_salt, _creationCode, 0);
    }
}

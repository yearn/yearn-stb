// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Proxy} from "@zkevm-stb/Proxy.sol";
import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";
import {IPolygonZkEVMBridge} from "./interfaces/Polygon/IPolygonZkEVMBridge.sol";

/**
 * @title DeployerBase
 * @notice To be inherited by the L1 and L2 Deployer's for common functionality.
 */
abstract contract DeployerBase {
    bytes32 public constant ESCROW_IMPLEMENTATION =
        keccak256("Escrow Implementation");
    bytes32 public constant L1_DEPLOYER = keccak256("L1 Deployer");
    bytes32 public constant L2_DEPLOYER = keccak256("L2 Deployer");

    /// @notice Address of the ICREATE3Factory contract used for deployment
    ICREATE3Factory internal constant create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    /// @notice Immutable original chain ID
    uint256 public immutable originalChainID;

    /// @notice Address of the PolygonZkEVMBridge contract
    IPolygonZkEVMBridge public immutable polygonZkEVMBridge;

    constructor(address _polygonZkEVMBridge) {
        polygonZkEVMBridge = IPolygonZkEVMBridge(_polygonZkEVMBridge);
        originalChainID = block.chainid;
    }

    /**
     * @notice Abstract functions to get the Layer 1 deployer address
     * @return Address of the Layer 1 deployer
     */
    function getL1Deployer() public view virtual returns (address);

    /**
     * @notice Abstract functions to get the Layer 2 deployer address
     * @return Address of the Layer 2 deployer
     */
    function getL2Deployer() public view virtual returns (address);

    /**
     * @notice Abstract functions to get the Escrow Implementation address
     * @return Address of the Escrow Implementation.
     */
    function getEscrowImplementation() external view virtual returns (address);

    /**
     * @notice Get expected L2 token address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L2 token contract
     */
    function getL2TokenAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                getL2Deployer(),
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
            create3Factory.getDeployed(
                getL1Deployer(),
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
            create3Factory.getDeployed(
                getL2Deployer(),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _l1TokenAddress))
            );
    }

    /**
     * @notice Get expected L2 converter address for a given asset
     * @param _l1TokenAddress Address of the L1 token
     * @return Address of the expected L2 converter contract
     */
    function getL2ConvertorAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                getL2Deployer(),
                keccak256(
                    abi.encodePacked(
                        bytes("L2TokenConverter:"),
                        _l1TokenAddress
                    )
                )
            );
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

        return create3Factory.deploy(_salt, _creationCode);
    }
}

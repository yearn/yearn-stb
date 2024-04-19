// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IPolygonZkEVMBridge} from "./interfaces/Polygon/IPolygonZkEVMBridge.sol";

abstract contract DeployerBase {
    bytes32 public constant ESCROW_IMPLEMENTATION =
        keccak256("Escrow Implementation");

    bytes32 public constant L1_DEPLOYER = keccak256("L1 Deployer");

    bytes32 public constant L2_DEPLOYER = keccak256("L2 Deployer");

    ICREATE3Factory internal constant create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    uint256 public immutable originalChainID;

    IPolygonZkEVMBridge public immutable polygonZkEVMBridge;

    constructor(address _polygonZkEVMBridge) {
        polygonZkEVMBridge = IPolygonZkEVMBridge(_polygonZkEVMBridge);
        originalChainID = block.chainid;
    }

    function getL1Deployer() public view virtual returns (address);

    function getL2Deployer() public view virtual returns (address);

    function getL1EscrowAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL1EscrowAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL1EscrowAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                getL1Deployer(),
                keccak256(abi.encodePacked(bytes("L1Escrow:"), _symbol))
            );
    }

    function getL2EscrowAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2EscrowAddress(bytes(ERC20(_asset).symbol()));
    }

    // Address will be the L2 deployer
    function _getL2EscrowAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                getL2Deployer(),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _symbol))
            );
    }

    function getL2TokenAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2TokenAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL2TokenAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                getL2Deployer(),
                keccak256(abi.encodePacked(bytes("L2Token:"), _symbol))
            );
    }

    function getL2ConvertorAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2ConvertorAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL2ConvertorAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                getL2Deployer(),
                keccak256(abi.encodePacked(bytes("L2TokenConverter:"), _symbol))
            );
    }
}

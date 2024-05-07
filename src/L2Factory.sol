// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L2Deployer} from "./L2Deployer.sol";
import {L2Token} from "@zkevm-stb/L2Token.sol";
import {L2Escrow} from "@zkevm-stb/L2Escrow.sol";
import {L2TokenConverter} from "@zkevm-stb/L2TokenConverter.sol";

/// @title Factory for deployment of L2 Contracts.
contract L2Factory {
    address public l2Deployer;

    address public immutable l1Deployer;

    address public immutable polygonZkEVMBridge;

    address public immutable l2TokenImplementation;

    address public immutable l2EscrowImplementation;

    address public immutable l2ConverterImplementation;

    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    constructor(address _l1Deployer, address _polygonZkEVMBridge) {
        l1Deployer = _l1Deployer;
        polygonZkEVMBridge = _polygonZkEVMBridge;
        l2TokenImplementation = address(new L2Token());
        l2EscrowImplementation = address(new L2Escrow());
        l2ConverterImplementation = address(new L2TokenConverter());
    }

    /**
     * @notice Function triggered by the bridge once a message is received from the other network
     * @param originAddress Origin address that the message was sended
     * @param originNetwork Origin network that the message was sended ( not usefull for this contract)
     * @param data Abi encoded metadata
     */
    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable {
        // Can only be called by the bridge
        require(
            polygonZkEVMBridge == msg.sender,
            "L2Factory: Not PolygonZkEVMBridge"
        );
        require(
            l1Deployer == originAddress,
            "L2Factory: Not deployer contract"
        );
        require(
            ORIGIN_NETWORK_ID == originNetwork,
            "L2Deployer: Not counterpart network"
        );

        (address _l2Admin, address _riskManager, address _escrowManager) = abi
            .decode(data, (address, address, address));

        l2Deployer = address(
            new L2Deployer(
                _l2Admin,
                l1Deployer,
                _riskManager,
                _escrowManager,
                polygonZkEVMBridge,
                l2TokenImplementation,
                l2EscrowImplementation,
                l2ConverterImplementation
            )
        );
    }
}

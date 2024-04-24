// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

interface IBridgeMessageReceiver {
    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable;
}

contract MockBridge {
    event BridgeEvent(
        uint8 leafType,
        uint32 originNetwork,
        address originAddress,
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 amount,
        bytes metadata,
        uint32 depositCount
    );

    uint32 public L1_NETWORK_ID = 0;
    uint32 public L2_NETWORK_ID = 1;

    address public polygonRollupManager =
        0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2;

    uint256 public depositCount;

    function bridgeMessage(
        uint32 destinationNetwork,
        address destinationAddress,
        bool,
        bytes calldata metadata
    ) external payable {
        uint32 originNetwork = destinationNetwork == L2_NETWORK_ID
            ? L1_NETWORK_ID
            : L2_NETWORK_ID;

        IBridgeMessageReceiver(destinationAddress).onMessageReceived(
            msg.sender,
            originNetwork,
            metadata
        );

        emit BridgeEvent(
            1,
            originNetwork,
            msg.sender,
            destinationNetwork,
            destinationAddress,
            0,
            metadata,
            uint32(depositCount)
        );
    }
}

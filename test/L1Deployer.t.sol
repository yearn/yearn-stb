// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L2Deployer, L1YearnEscrow, L2Token, L2Escrow, L2TokenConverter, IPolygonZkEVMBridge} from "./utils/Setup.sol";

contract L1DeployerTest is Setup {
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

    function setUp() public virtual override {
        super.setUp();
    }
}

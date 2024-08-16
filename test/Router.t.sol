// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IPolygonZkEVMBridge, IVault, L1Deployer, ERC20} from "./utils/Setup.sol";

import {STBRouter} from "../src/router/STBRouter.sol";

contract L1DeployerTest is Setup {
    function setUp() public override {
        super.setUp();
    }
}

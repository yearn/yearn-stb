// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {BatchScript, console2} from "./lib/BatchScript.sol";

import {L1Deployer, IPolygonRollupContract, IPolygonRollupManager} from "../src/L1Deployer.sol";
import {L2Deployer} from "../src/L2Deployer.sol";

contract SetupDeployer is BatchScript {

    address public ZK_EVM_BRIDGE = 0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;

    L1Deployer public L1_DEPLOYER = L1Deployer(0x49dC846d5EDA92dDC4985b7B7BBaD4F9b05B7597);

    address public safe;

    function run() external {
        
        // Get all args
        address l2Deployer = vm.envAddress("L2_DEPLOYER");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        if(l2Deployer == address(0)) {

            console.log("Deploying an L2 Deployer...");

            address l2Admin = vm.envAddress("L2_ADMIN");
            require(l2Admin != address(0), "L2 Admin ZERO_ADDRESS");
            address l2RiskManager = vm.envAddress("L2_RISK_MANAGER");
            require(l2RiskManager != address(0), "L2 Risk Manager ZERO_ADDRESS");
            address l2EscrowManager = vm.envAddress("L2_ESCROW_MANAGER");
            require(l2EscrowManager != address(0), "L2 Escrow Manager ZERO_ADDRESS");

            // Start L2 RPC
            vm.createSelectFork(vm.envString("L2_RPC_URL"));

            vm.startBroadcast(deployerPrivateKey);

            // Deploy L2 Deployer
            l2Deployer = address(new L2Deployer(
                l2Admin,
                address(L1_DEPLOYER),
                l2RiskManager,
                l2EscrowManager,
                ZK_EVM_BRIDGE
            ));

            vm.stopBroadcast();

            console.log("L2 Deployer deployed to ", address(l2Deployer));
        }

        // Take L2 deployer address
        // Start Mainnet RPC
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        uint32 rollupID = uint32(vm.envUint("ROLLUP_ID"));
        address l1EscrowManager = vm.envAddress("L1_ESCROW_MANAGER");

        console.log("Registering Rollup with ID ", rollupID);
        console.log("Using ", l2Deployer, " as the L2 Deployer");

        require(L1_DEPLOYER.getRollupContract(rollupID) == address(0), "Already registered");

        safe = L1_DEPLOYER.rollupManager()
            .rollupIDToRollupData(rollupID)
            .rollupContract.admin();

        bytes memory txn = abi.encodeCall(
            L1Deployer.testRegisterRollup,
            (rollupID, address(l2Deployer), l1EscrowManager)
        );

        addToBatch(address(L1_DEPLOYER), txn);

        executeBatch(safe, true);

        require(L1_DEPLOYER.getRollupContract(rollupID) != address(0), "txn failed");
    }
}
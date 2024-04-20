// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console} from "./utils/Setup.sol";
import {Roles} from "@yearn-vaults/interfaces/Roles.sol";

contract SetupTest is Setup {

    uint256 public managementRoles = Roles.REPORTING_MANAGER |
                    Roles.DEBT_MANAGER |
                    Roles.QUEUE_MANAGER |
                    Roles.DEPOSIT_LIMIT_MANAGER |
                    Roles.DEBT_PURCHASER |
                    Roles.PROFIT_UNLOCK_MANAGER;

    uint256 public keeperRoles = Roles.REPORTING_MANAGER;
    uint256 public debtAllocatorRoles = Roles.REPORTING_MANAGER | Roles.DEBT_MANAGER;

    function setUp() public virtual override{
        super.setUp();
    }

    // Check all contracts were deployed correctly.
    function test_setupOk() public {
        assertNeq(address(registry), address(0));
        assertNeq(address(accountant), address(0));
        assertNeq(address(allocatorFactory), address(0));
        assertNeq(address(l1Deployer), address(0));
        assertNeq(address(l1EscrowImpl), address(0));
        assertNeq(address(l2Deployer), address(0));
        assertNeq(address(l2EscrowImpl), address(0));
        assertNeq(address(l2TokenImpl), address(0));
        assertNeq(address(l2TokenConverterImpl), address(0));
    }

    // Check the L1 deployer is setup correctly and working.
    function test_l1DeployerSetup() public {
        assertEq(l1Deployer.name(), "L1 Stake the Bridge Deployer");
        assertEq(l1Deployer.getGovernator(), governator);
        assertEq(l1Deployer.getCzar(), czar);
        assertEq(l1Deployer.getCzarRoles(), Roles.ALL);
        assertEq(l1Deployer.getManagement(), management);
        assertEq(l1Deployer.getManagementRoles(), managementRoles);
        assertEq(l1Deployer.getKeeper(), keeper);
        assertEq(l1Deployer.getKeeperRoles(), keeperRoles);
        assertEq(l1Deployer.getEmergencyAdmin(), emergencyAdmin);
        assertEq(l1Deployer.getEmergencyAdminRoles(), Roles.EMERGENCY_MANAGER);
        assertEq(l1Deployer.getDebtAllocator(), address(0));
        assertEq(l1Deployer.getDebtAllocatorRoles(), debtAllocatorRoles);
        assertEq(l1Deployer.getPendingGovernator(), address(0));
        assertEq(l1Deployer.getAccountant(), address(accountant));
        assertEq(l1Deployer.getRegistry(), address(registry));
        assertEq(l1Deployer.getAllocatorFactory(), address(allocatorFactory));
        assertEq(l1Deployer.getL1Deployer(), address(l1Deployer));
        assertEq(l1Deployer.getL2Deployer(), address(l2Deployer));
        assertEq(l1Deployer.getEscrowImplementation(), address(l1EscrowImpl));
    }

    function test_l2DeployerSetup() public {
        assertEq(l2Deployer.name(), "L2 Stake the Bridge Deployer");
        assertEq(l2Deployer.getL1Deployer(), address(l1Deployer));
        assertEq(l2Deployer.getL2Deployer(), address(l2Deployer));
        assertEq(l2Deployer.getEscrowImplementation(), address(l2EscrowImpl));
        assertEq(l2Deployer.getL2Admin(), l2Admin);
        assertEq(l2Deployer.getPendingAdmin(), address(0));
        assertEq(l2Deployer.getRiskManager(), l2RiskManager);
        assertEq(l2Deployer.getEscrowManager(), l2EscrowManager);
        assertEq(l2Deployer.getTokenImplementation(), address(l2TokenImpl));
        assertEq(l2Deployer.getConvertorImplementation(), address(l2TokenConverterImpl));
    }

    function test_newVault() public {
        // Pretend to be the rollup 1
        uint32 rollupID = 1;
        address admin = 0x242daE44F5d8fb54B198D03a94dA45B5a4413e21;
        address manager = address(123);

        vm.expectRevert("!admin");
        l1Deployer.registerRollup(rollupID, manager); 

        vm.prank(admin);
        l1Deployer.registerRollup(rollupID, manager);

        l1Deployer.newAsset(rollupID, address(asset));
    }

    function test_newToken() public {
        uint32 rollupID = 1;
        address admin = 0x242daE44F5d8fb54B198D03a94dA45B5a4413e21;
        address manager = address(123);

        vm.prank(admin);
        l1Deployer.registerRollup(rollupID, manager);

        address _l1Escrow;
        ( , _l1Escrow) =  l1Deployer.newAsset(rollupID, address(asset));
        bytes memory data = abi.encode(address(asset), _l1Escrow, asset.name(), bytes(asset.symbol()));

        vm.prank(polygonZkEVMBridge);
        l2Deployer.onMessageReceived(address(l1Deployer), 0, data);
    }
}
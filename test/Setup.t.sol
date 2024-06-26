// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, Roles} from "./utils/Setup.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetupTest is Setup {
    uint256 public managementRoles =
        Roles.REPORTING_MANAGER |
            Roles.DEBT_MANAGER |
            Roles.QUEUE_MANAGER |
            Roles.DEPOSIT_LIMIT_MANAGER |
            Roles.DEBT_PURCHASER |
            Roles.PROFIT_UNLOCK_MANAGER;

    uint256 public keeperRoles = Roles.REPORTING_MANAGER;
    uint256 public debtAllocatorRoles =
        Roles.REPORTING_MANAGER | Roles.DEBT_MANAGER;

    function setUp() public virtual override {
        super.setUp();
    }

    // Check all contracts were deployed correctly.
    function test_setupOk() public {
        assertNeq(address(registry), address(0));
        assertNeq(address(accountant), address(0));
        assertNeq(address(allocatorFactory), address(0));
        assertNeq(address(l1Deployer), address(0));
        assertNeq(address(roleManager), address(0));
        assertNeq(address(l1EscrowImpl), address(0));
        assertNeq(address(l2Deployer), address(0));
        assertNeq(address(l2EscrowImpl), address(0));
        assertNeq(address(l2TokenImpl), address(0));
        assertNeq(address(l2TokenConverterImpl), address(0));
    }

    // Check the L1 deployer is setup correctly and working.
    function test_roleManagerSetup() public {
        assertEq(roleManager.name(), "Stake the Bridge Role Manager");
        assertEq(
            roleManager.getPositionHolder(roleManager.GOVERNATOR()),
            governator
        );
        assertEq(roleManager.getPositionHolder(roleManager.CZAR()), czar);
        assertEq(roleManager.getPositionRoles(roleManager.CZAR()), Roles.ALL);
        assertEq(
            roleManager.getPositionHolder(roleManager.MANAGEMENT()),
            management
        );
        assertEq(
            roleManager.getPositionRoles(roleManager.MANAGEMENT()),
            managementRoles
        );
        assertEq(roleManager.getPositionHolder(roleManager.KEEPER()), keeper);
        assertEq(
            roleManager.getPositionRoles(roleManager.KEEPER()),
            keeperRoles
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.EMERGENCY_ADMIN()),
            emergencyAdmin
        );
        assertEq(
            roleManager.getPositionRoles(roleManager.EMERGENCY_ADMIN()),
            Roles.EMERGENCY_MANAGER
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.DEBT_ALLOCATOR()),
            address(0)
        );
        assertEq(
            roleManager.getPositionRoles(roleManager.DEBT_ALLOCATOR()),
            debtAllocatorRoles
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.PENDING_GOVERNATOR()),
            address(0)
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.ACCOUNTANT()),
            address(accountant)
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.REGISTRY()),
            address(registry)
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.ALLOCATOR_FACTORY()),
            address(allocatorFactory)
        );
    }

    function test_l1DeployerSetup() public {
        assertEq(l1Deployer.name(), "L1 Stake the Bridge Deployer");
        assertEq(
            l1Deployer.getPositionHolder(l1Deployer.L1_DEPLOYER()),
            address(l1Deployer)
        );
        assertEq(l1Deployer.getL2Deployer(l2RollupID), address(0));
        assertEq(
            l1Deployer.getPositionHolder(l1Deployer.ESCROW_IMPLEMENTATION()),
            address(l1EscrowImpl)
        );
    }

    function test_l2DeployerSetup() public {
        assertEq(l2Deployer.name(), "L2 Stake the Bridge Deployer");
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.L1_DEPLOYER()),
            address(l1Deployer)
        );
        assertEq(l2Deployer.getL2Deployer(l2RollupID), address(l2Deployer));
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.ESCROW_IMPLEMENTATION()),
            address(l2EscrowImpl)
        );
        assertEq(l2Deployer.getPositionHolder(l2Deployer.L2_ADMIN()), l2Admin);
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.PENDING_ADMIN()),
            address(0)
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.RISK_MANAGER()),
            l2RiskManager
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.ESCROW_MANAGER()),
            l2EscrowManager
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.TOKEN_IMPLEMENTATION()),
            address(l2TokenImpl)
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.CONVERTER_IMPLEMENTATION()),
            address(l2TokenConverterImpl)
        );
    }
}

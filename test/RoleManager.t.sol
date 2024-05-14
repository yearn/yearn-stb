// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IPolygonZkEVMBridge, IVault, L1Deployer, ERC20} from "./utils/Setup.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "../src/interfaces/Polygon/IPolygonRollupManager.sol";

contract RoleManagerTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_newDefaultVault() public {
        assertEq(roleManager.getVault(address(asset)), address(0));

        vm.expectRevert("!allowed");
        roleManager.newDefaultVault(address(asset));

        vm.prank(governator);
        address vault = roleManager.newDefaultVault(address(asset));

        assertNeq(vault, address(0));
        assertEq(roleManager.getVault(address(asset)), vault);

        assertEq(IVault(vault).accountant(), address(accountant));
        assertNeq(roleManager.getDebtAllocator(vault), address(0));
        assertTrue(roleManager.isVaultsRoleManager(vault));
    }

    function test_updateGovernator() public {
        assertEq(
            roleManager.getPositionHolder(roleManager.GOVERNATOR()),
            governator
        );
        assertEq(
            roleManager.getPositionHolder(roleManager.PENDING_GOVERNATOR()),
            address(0)
        );
        bytes32 GOVERNATOR = roleManager.GOVERNATOR();
        bytes32 PENDING_GOV = roleManager.PENDING_GOVERNATOR();

        vm.expectRevert("!allowed");
        roleManager.setPositionHolder(GOVERNATOR, czar);

        vm.expectRevert("!two step flow");
        vm.prank(governator);
        roleManager.setPositionHolder(GOVERNATOR, czar);

        vm.prank(governator);
        roleManager.setPositionHolder(PENDING_GOV, czar);

        assertEq(roleManager.getPositionHolder(GOVERNATOR), governator);
        assertEq(roleManager.getPositionHolder(PENDING_GOV), czar);

        vm.expectRevert("!allowed");
        vm.prank(governator);
        roleManager.acceptGovernator();

        vm.prank(czar);
        roleManager.acceptGovernator();

        assertEq(roleManager.getPositionHolder(roleManager.GOVERNATOR()), czar);
        assertEq(
            roleManager.getPositionHolder(roleManager.PENDING_GOVERNATOR()),
            address(0)
        );
    }
}

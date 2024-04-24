// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IPolygonZkEVMBridge} from "./utils/Setup.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "../src/interfaces/Polygon/IPolygonRollupManager.sol";

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

    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed manager
    );

    event UpdateRollupManager(uint32 indexed rollupID, address indexed manager);

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    function setUp() public virtual override {
        super.setUp();
    }

    function test_registerRollup_admin() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getRollupManager(rollupID), address(0));
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));

        address rollupContract = address(
            IPolygonRollupManager(polygonZkEVMBridge.polygonRollupManager())
                .rollupIDToRollupData(rollupID)
                .rollupContract
        );
        address rollupAdmin = address(
            IPolygonRollupManager(polygonZkEVMBridge.polygonRollupManager())
                .rollupIDToRollupData(rollupID)
                .rollupContract
                .admin()
        );

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit RegisteredNewRollup(rollupID, rollupContract, czar);
        vm.prank(rollupAdmin);
        l1Deployer.registerRollup(rollupID, czar);

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getRollupManager(rollupID), czar);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));

        vm.expectRevert();
        vm.prank(rollupAdmin);
        l1Deployer.registerRollup(rollupID, governator);

        vm.expectRevert("!admin");
        vm.prank(czar);
        l1Deployer.updateRollupManager(rollupID, governator);

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit UpdateRollupManager(rollupID, governator);
        vm.prank(rollupAdmin);
        l1Deployer.updateRollupManager(rollupID, governator);

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getRollupManager(rollupID), governator);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));
    }
}

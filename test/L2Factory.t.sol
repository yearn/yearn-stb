// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {MockBridge} from "./mocks/MockBridge.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "../src/interfaces/Polygon/IPolygonRollupManager.sol";
import {Setup, console, L2Token, L2Escrow, L2TokenConverter, L2Factory, L2Deployer, IPolygonZkEVMBridge} from "./utils/Setup.sol";

contract L2FactoryTest is Setup {
    event RegisteredNewRollup(
        uint32 indexed rollupID,
        address indexed rollupContract,
        address indexed escrowManager
    );

    function setUp() public virtual override {
        polygonZkEVMBridge = IPolygonZkEVMBridge(address(new MockBridge()));
        super.setUp();
    }

    function deployL2Contracts() public override {
        l2Factory = new L2Factory(
            address(l1Deployer),
            address(polygonZkEVMBridge)
        );

        l2TokenImpl = L2Token(l2Factory.l2TokenImplementation());

        l2EscrowImpl = L2Escrow(l2Factory.l2EscrowImplementation());

        l2TokenConverterImpl = L2TokenConverter(
            l2Factory.l2ConverterImplementation()
        );
    }

    function test_deployL2Deployer() public {
        bytes memory data = abi.encode(l2Admin, l2RiskManager, l2EscrowManager);

        vm.expectRevert("L2Factory: Not PolygonZkEVMBridge");
        l2Factory.onMessageReceived(address(l1Deployer), l1RollupID, data);

        vm.expectRevert("L2Factory: Not deployer contract");
        vm.prank(address(polygonZkEVMBridge));
        l2Factory.onMessageReceived(address(69), l1RollupID, data);

        vm.expectRevert("L2Factory: Not counterpart network");
        vm.prank(address(polygonZkEVMBridge));
        l2Factory.onMessageReceived(address(l1Deployer), l2RollupID, data);

        vm.prank(address(polygonZkEVMBridge));
        l2Factory.onMessageReceived(address(l1Deployer), l1RollupID, data);

        l2Deployer = L2Deployer(l2Factory.l2Deployer());
        assertNeq(address(l2Deployer), address(0));
    }

    function test_l1AdminDeploysDeployer_notRegistered() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l2Factory.l2Deployer(), address(0));

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

        vm.expectRevert("!admin");
        l1Deployer.deployL2Deployer(
            rollupID,
            l2Admin,
            l2RiskManager,
            l2EscrowManager
        );

        vm.expectRevert("ZERO ADDRESS");
        vm.prank(rollupAdmin);
        l1Deployer.deployL2Deployer(
            rollupID,
            address(0),
            l2RiskManager,
            l2EscrowManager
        );

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit RegisteredNewRollup(rollupID, rollupContract, rollupAdmin);
        vm.prank(rollupAdmin);
        l1Deployer.deployL2Deployer(
            rollupID,
            l2Admin,
            l2RiskManager,
            l2EscrowManager
        );

        l2Deployer = L2Deployer(l2Factory.l2Deployer());
        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertNeq(address(l2Deployer), address(0));
        assertEq(l2Deployer.getPositionHolder(l2Deployer.L2_ADMIN()), l2Admin);
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.RISK_MANAGER()),
            l2RiskManager
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.ESCROW_MANAGER()),
            l2EscrowManager
        );
    }

    function test_l1AdminDeploysDeployer_registered() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l2Factory.l2Deployer(), address(0));

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
        emit RegisteredNewRollup(rollupID, rollupContract, rollupAdmin);
        l1Deployer.registerRollup(rollupID, address(0));

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);

        vm.expectRevert("!admin");
        l1Deployer.deployL2Deployer(
            rollupID,
            l2Admin,
            l2RiskManager,
            l2EscrowManager
        );

        vm.expectRevert("ZERO ADDRESS");
        vm.prank(rollupAdmin);
        l1Deployer.deployL2Deployer(
            rollupID,
            address(0),
            l2RiskManager,
            l2EscrowManager
        );

        vm.prank(rollupAdmin);
        l1Deployer.deployL2Deployer(
            rollupID,
            l2Admin,
            l2RiskManager,
            l2EscrowManager
        );

        l2Deployer = L2Deployer(l2Factory.l2Deployer());
        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertNeq(address(l2Deployer), address(0));
        assertEq(l2Deployer.getPositionHolder(l2Deployer.L2_ADMIN()), l2Admin);
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.RISK_MANAGER()),
            l2RiskManager
        );
        assertEq(
            l2Deployer.getPositionHolder(l2Deployer.ESCROW_MANAGER()),
            l2EscrowManager
        );
    }
}

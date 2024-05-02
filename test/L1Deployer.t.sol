// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IPolygonZkEVMBridge, IVault, L1Deployer, ERC20} from "./utils/Setup.sol";
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
        address indexed escrowManager
    );

    event UpdateEscrowManager(
        uint32 indexed rollupID,
        address indexed escrowManager
    );

    event NewL1Escrow(uint32 indexed rollupID, address indexed l1Escrow);

    function setUp() public virtual override {
        super.setUp();
    }

    function test_registerRollup_admin() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getEscrowManager(rollupID), address(0));

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
        assertEq(l1Deployer.getEscrowManager(rollupID), czar);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));

        vm.expectRevert();
        vm.prank(rollupAdmin);
        l1Deployer.registerRollup(rollupID, governator);

        vm.expectRevert("!admin");
        vm.prank(czar);
        l1Deployer.updateEscrowManager(rollupID, governator);

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit UpdateEscrowManager(rollupID, governator);
        vm.prank(rollupAdmin);
        l1Deployer.updateEscrowManager(rollupID, governator);

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getEscrowManager(rollupID), governator);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));
    }

    function test_registerRollup_rando() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getEscrowManager(rollupID), address(0));
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
        emit RegisteredNewRollup(rollupID, rollupContract, rollupAdmin);
        l1Deployer.registerRollup(rollupID, czar);

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getEscrowManager(rollupID), rollupAdmin);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));

        vm.expectRevert();
        vm.prank(rollupAdmin);
        l1Deployer.registerRollup(rollupID, governator);

        vm.expectRevert("!admin");
        l1Deployer.updateEscrowManager(rollupID, governator);

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit UpdateEscrowManager(rollupID, governator);
        vm.prank(rollupAdmin);
        l1Deployer.updateEscrowManager(rollupID, governator);

        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getEscrowManager(rollupID), governator);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));
    }

    function test_registerRollup_badId() public {
        uint32 rollupID = 69;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getEscrowManager(rollupID), address(0));
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));

        vm.expectRevert();
        l1Deployer.registerRollup(rollupID, czar);
    }

    function test_newEscrow() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getEscrowManager(rollupID), address(0));
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));
        assertEq(l1Deployer.getVault(address(asset)), address(0));

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

        address _l1Escrow = l1Deployer.getL1EscrowAddress(
            address(asset),
            rollupID
        );

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit NewL1Escrow(rollupID, _l1Escrow);
        (, address _vault) = l1Deployer.newEscrow(rollupID, address(asset));

        // Rollup should be registered, vault and escrow deployed
        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getEscrowManager(rollupID), rollupAdmin);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), _l1Escrow);
        assertEq(l1Deployer.getVault(address(asset)), _vault);

        IVault vault = IVault(_vault);

        assertEq(vault.accountant(), address(accountant));
        assertEq(vault.asset(), address(asset));
        assertEq(vault.deposit_limit(), 2 ** 256 - 1);
        (
            address asset_,
            uint32 rollupID_,
            address _debtAllocator,
            uint96 _index
        ) = l1Deployer.vaultConfig(_vault);
        assertTrue(_debtAllocator != address(0));
        assertEq(_index, 0);
        assertEq(rollupID_, 0);
        assertEq(asset_, address(asset));

        L1YearnEscrow escrow = L1YearnEscrow(_l1Escrow);

        assertEq(escrow.owner(), rollupAdmin);
        assertTrue(escrow.hasRole(escrow.ESCROW_MANAGER_ROLE(), rollupAdmin));
        assertEq(escrow.polygonZkEVMBridge(), address(polygonZkEVMBridge));
        assertEq(
            escrow.counterpartContract(),
            l1Deployer.getL2EscrowAddress(address(asset))
        );
        assertEq(escrow.counterpartNetwork(), rollupID);
        assertEq(address(escrow.originTokenAddress()), address(asset));
        assertEq(
            address(escrow.wrappedTokenAddress()),
            l1Deployer.getL2TokenAddress(address(asset))
        );
        assertEq(address(escrow.vaultAddress()), address(vault));
        assertEq(escrow.minimumBuffer(), 0);
        assertEq(
            asset.allowance(address(escrow), address(vault)),
            2 ** 256 - 1
        );
    }

    function test_customVault_preDeployed() public {
        uint32 rollupID = 1;
        assertEq(l1Deployer.getRollupContract(rollupID), address(0));
        assertEq(l1Deployer.getEscrowManager(rollupID), address(0));
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), address(0));
        assertEq(l1Deployer.getVault(address(asset)), address(0));

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

        l1Deployer.registerRollup(rollupID, rollupAdmin);

        address _vault = vaultFactory.deploy_new_vault(
            address(asset),
            "test Vault",
            "tsVault",
            rollupAdmin,
            100
        );

        vm.prank(rollupAdmin);
        IVault(_vault).transfer_role_manager(address(l1Deployer));

        address _l1Escrow = l1Deployer.getL1EscrowAddress(
            address(asset),
            rollupID
        );

        vm.expectRevert("!admin");
        l1Deployer.newCustomVault(rollupID, address(asset), _vault);

        vm.expectEmit(true, true, true, true, address(l1Deployer));
        emit NewL1Escrow(rollupID, _l1Escrow);
        vm.prank(rollupAdmin);
        l1Deployer.newCustomVault(rollupID, address(asset), _vault);

        // Rollup should be registered, vault and escrow deployed
        assertEq(l1Deployer.getRollupContract(rollupID), rollupContract);
        assertEq(l1Deployer.getEscrowManager(rollupID), rollupAdmin);
        assertEq(l1Deployer.getEscrow(rollupID, address(asset)), _l1Escrow);
        assertEq(l1Deployer.getVault(address(asset)), address(0));
        assertEq(l1Deployer.getVault(address(asset), rollupID), _vault);

        IVault vault = IVault(_vault);

        assertEq(vault.accountant(), address(accountant));
        assertEq(vault.asset(), address(asset));
        (
            address asset_,
            uint32 rollupID_,
            address _debtAllocator,
            uint96 _index
        ) = l1Deployer.vaultConfig(_vault);
        assertTrue(_debtAllocator != address(0));
        assertEq(_index, 0);
        assertEq(rollupID_, rollupID);
        assertEq(asset_, address(asset));

        L1YearnEscrow escrow = L1YearnEscrow(_l1Escrow);

        assertEq(escrow.owner(), rollupAdmin);
        assertTrue(escrow.hasRole(escrow.ESCROW_MANAGER_ROLE(), rollupAdmin));
        assertEq(escrow.polygonZkEVMBridge(), address(polygonZkEVMBridge));
        assertEq(
            escrow.counterpartContract(),
            l1Deployer.getL2EscrowAddress(address(asset))
        );
        assertEq(escrow.counterpartNetwork(), rollupID);
        assertEq(address(escrow.originTokenAddress()), address(asset));
        assertEq(
            address(escrow.wrappedTokenAddress()),
            l1Deployer.getL2TokenAddress(address(asset))
        );
        assertEq(address(escrow.vaultAddress()), address(vault));
        assertEq(escrow.minimumBuffer(), 0);
        assertEq(
            asset.allowance(address(escrow), address(vault)),
            2 ** 256 - 1
        );
    }
}

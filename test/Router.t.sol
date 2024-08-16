// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IPolygonZkEVMBridge, IVault, L1Deployer, ERC20} from "./utils/Setup.sol";
import {IPolygonRollupManager, IPolygonRollupContract} from "../src/interfaces/Polygon/IPolygonRollupManager.sol";

import {STBRouter} from "../src/router/STBRouter.sol";

interface ISTBRouter {
    function bridge(uint32 _rollupID, address _asset) external;
}

contract RouterTest is Setup {
    STBRouter public router;

    address public permit2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    L1YearnEscrow public mockEscrow;

    function setUp() public override {
        super.setUp();

        router = new STBRouter(weth, permit2, address(l1Deployer));

        address rollupAdmin = address(
            IPolygonRollupManager(polygonZkEVMBridge.polygonRollupManager())
                .rollupIDToRollupData(l2RollupID)
                .rollupContract
                .admin()
        );

        vm.prank(rollupAdmin);
        l1Deployer.registerRollup(l2RollupID, czar, address(l2Deployer));

        (address _l1Escrow, address _vault) = l1Deployer.newEscrow(
            l2RollupID,
            address(asset)
        );
        mockEscrow = L1YearnEscrow(_l1Escrow);
        vault = IVault(_vault);
    }

    function test_bridge_withDefaults(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        airdrop(asset, user, _amount);

        router.approve(asset, address(mockEscrow), 2 ** 256 - 1);

        vm.prank(user);
        asset.approve(address(router), _amount);

        bytes memory data = abi.encode(user, _amount);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.bridge(l2RollupID, address(asset));

        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(vault)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);
    }

    function test_bridge_withAmount(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        airdrop(asset, user, _amount);

        uint256 toBridge = _amount - 100;

        router.approve(asset, address(mockEscrow), 2 ** 256 - 1);

        vm.prank(user);
        asset.approve(address(router), _amount);

        bytes memory data = abi.encode(user, toBridge);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.bridge(l2RollupID, address(asset), toBridge);

        assertEq(asset.balanceOf(user), _amount - toBridge);
        assertEq(asset.balanceOf(address(vault)), toBridge);
        assertEq(vault.balanceOf(address(mockEscrow)), toBridge);
    }

    function test_bridge_customReceiver(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        airdrop(asset, user, _amount);

        uint256 toBridge = _amount - 100;

        router.approve(asset, address(mockEscrow), 2 ** 256 - 1);

        vm.prank(user);
        asset.approve(address(router), _amount);

        bytes memory data = abi.encode(czar, toBridge);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.bridge(l2RollupID, address(asset), toBridge, czar);

        assertEq(asset.balanceOf(user), _amount - toBridge);
        assertEq(asset.balanceOf(address(vault)), toBridge);
        assertEq(vault.balanceOf(address(mockEscrow)), toBridge);
    }

    function test_bridge_withMulticall(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        airdrop(asset, user, _amount);

        vm.prank(user);
        asset.approve(address(router), _amount);

        bytes[] memory multiCallData = new bytes[](2);

        multiCallData[0] = abi.encodeWithSelector(
            router.approve.selector,
            asset,
            address(mockEscrow),
            2 ** 256 - 1
        );
        multiCallData[1] = abi.encodeWithSelector(
            ISTBRouter.bridge.selector,
            l2RollupID,
            address(asset)
        );

        bytes memory data = abi.encode(user, _amount);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.multicall(multiCallData);

        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(vault)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);
    }

    function test_bridge_eth() public {
        asset = ERC20(weth);
        (address _l1Escrow, address _vault) = l1Deployer.newEscrow(
            l2RollupID,
            address(asset)
        );
        mockEscrow = L1YearnEscrow(_l1Escrow);
        vault = IVault(_vault);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        router.approve(asset, address(mockEscrow), 2 ** 256 - 1);

        uint256 wethBalance = asset.balanceOf(user);
        uint256 _amount = user.balance;

        bytes memory data = abi.encode(user, _amount);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.bridgeEth{value: _amount}(l2RollupID, address(asset), user);

        assertEq(asset.balanceOf(user), wethBalance);
        assertEq(asset.balanceOf(address(vault)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);
        assertEq(user.balance, 0);
    }

    function test_bridge_ethWithMulticall() public {
        asset = ERC20(weth);
        (address _l1Escrow, address _vault) = l1Deployer.newEscrow(
            l2RollupID,
            address(asset)
        );
        mockEscrow = L1YearnEscrow(_l1Escrow);
        vault = IVault(_vault);

        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        uint256 wethBalance = asset.balanceOf(user);
        uint256 _amount = user.balance;

        bytes[] memory multiCallData = new bytes[](3);

        multiCallData[0] = abi.encodeWithSelector(
            router.approve.selector,
            asset,
            address(mockEscrow),
            2 ** 256 - 1
        );
        multiCallData[2] = abi.encodeWithSelector(
            router.bridgeEth.selector,
            l2RollupID,
            address(asset),
            user
        );

        bytes memory data = abi.encode(user, _amount);
        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l1RollupID,
            address(mockEscrow),
            l2RollupID,
            counterPart,
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        router.multicall{value: _amount}(multiCallData);

        assertEq(asset.balanceOf(user), wethBalance);
        assertEq(asset.balanceOf(address(vault)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);
        assertEq(user.balance, 0);
    }

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
}

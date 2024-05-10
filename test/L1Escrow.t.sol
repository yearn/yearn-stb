// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console, L1YearnEscrow, IVault} from "./utils/Setup.sol";

contract EscrowTest is Setup {
    address public l2TokenAddress;

    L1YearnEscrow public mockEscrow;

    function setUp() public virtual override {
        super.setUp();
        l2TokenAddress = l1Deployer.getL2TokenAddress(
            l2RollupID,
            address(asset)
        );
        vault = deployMockVault();
    }

    function test_implementationSetup() public {
        // No level should be initialized
        assertEq(l1EscrowImpl.owner(), address(0));
        assertEq(l2EscrowImpl.polygonZkEVMBridge(), address(0));
        assertEq(address(l1EscrowImpl.originTokenAddress()), address(0));
        assertEq(address(l1EscrowImpl.vaultAddress()), address(0));

        // Cannot be re-initialized
        vm.expectRevert();
        l1EscrowImpl.initialize(
            governator,
            czar,
            address(polygonZkEVMBridge),
            address(l2EscrowImpl),
            l2RollupID,
            address(asset),
            l2TokenAddress,
            address(vault)
        );

        assertEq(l1EscrowImpl.owner(), address(0));
        assertEq(l2EscrowImpl.polygonZkEVMBridge(), address(0));
        assertEq(address(l1EscrowImpl.originTokenAddress()), address(0));
        assertEq(address(l1EscrowImpl.vaultAddress()), address(0));
    }

    function test_newEscrow() public {
        bytes memory data = abi.encodeCall(
            L1YearnEscrow.initialize,
            (
                governator,
                czar,
                address(polygonZkEVMBridge),
                address(l2EscrowImpl),
                l2RollupID,
                address(asset),
                l2TokenAddress,
                address(vault)
            )
        );

        mockEscrow = L1YearnEscrow(_deployProxy(address(l1EscrowImpl), data));

        assertEq(mockEscrow.owner(), governator);
        assertTrue(mockEscrow.hasRole(mockEscrow.ESCROW_MANAGER_ROLE(), czar));
        assertEq(mockEscrow.polygonZkEVMBridge(), address(polygonZkEVMBridge));
        assertEq(mockEscrow.counterpartContract(), address(l2EscrowImpl));
        assertEq(mockEscrow.counterpartNetwork(), l2RollupID);
        assertEq(address(mockEscrow.originTokenAddress()), address(asset));
        assertEq(address(mockEscrow.wrappedTokenAddress()), l2TokenAddress);
        assertEq(address(mockEscrow.vaultAddress()), address(vault));
        assertEq(mockEscrow.minimumBuffer(), 0);
        assertEq(
            asset.allowance(address(mockEscrow), address(vault)),
            2 ** 256 - 1
        );
    }

    function test_bridgeAsset(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );
        mockEscrow = deployMockL1Escrow();

        // Simulate a bridge txn
        airdrop(asset, user, _amount);

        vm.prank(user);
        asset.approve(address(mockEscrow), _amount);

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
        mockEscrow.bridgeToken(user, _amount, true);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        // Withdraw half
        uint256 toWithdraw = _amount / 2;

        data = abi.encode(user, toWithdraw);

        vm.expectRevert(
            "TokenWrapped::PolygonBridgeBase: Not PolygonZkEVMBridge"
        );
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        vm.expectRevert(
            "TokenWrapped::PolygonBridgeBase: Not counterpart contract"
        );
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(address(l1EscrowImpl), l2RollupID, data);

        vm.expectRevert(
            "TokenWrapped::PolygonBridgeBase: Not counterpart network"
        );
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l1RollupID, data);

        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(vault.totalAssets(), _amount - toWithdraw);
        assertEq(asset.balanceOf(user), toWithdraw);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount - toWithdraw);

        data = abi.encode(user, _amount - toWithdraw);

        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(vault.totalAssets(), 0);
        assertEq(asset.balanceOf(user), _amount);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
    }

    function test_bridgeAsset_maxDepositLimit(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );
        mockEscrow = deployMockL1Escrow();

        vm.prank(governator);
        vault.set_deposit_limit(0);

        // Simulate a bridge txn
        airdrop(asset, user, _amount);

        vm.prank(user);
        asset.approve(address(mockEscrow), _amount);

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
        mockEscrow.bridgeToken(user, _amount, true);

        assertEq(vault.totalAssets(), 0);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);

        vm.prank(governator);
        vault.set_deposit_limit(_amount);

        airdrop(asset, user, _amount);

        vm.prank(user);
        asset.approve(address(mockEscrow), _amount);

        vm.prank(user);
        mockEscrow.bridgeToken(user, _amount, true);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        // Withdraw half
        uint256 toWithdraw = _amount + 10;

        data = abi.encode(user, toWithdraw);

        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(vault.totalAssets(), _amount - 10);
        assertEq(asset.balanceOf(user), toWithdraw);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount - 10);
    }

    function test_bridgeAsset_minimumBuffer(
        uint256 _amount,
        uint256 _minimumBuffer
    ) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        _minimumBuffer = bound(_minimumBuffer, 10, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        vm.expectRevert();
        mockEscrow.updateMinimumBuffer(_minimumBuffer);

        vm.prank(governator);
        mockEscrow.updateMinimumBuffer(_minimumBuffer);

        // expected amount the escrow will deposit to the vault
        uint256 toDeposit = _minimumBuffer >= _amount
            ? 0
            : _amount - _minimumBuffer;

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), toDeposit);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), _amount - toDeposit);
        assertEq(vault.balanceOf(address(mockEscrow)), toDeposit);

        // Withdraw everything
        bytes memory data = abi.encode(user, _amount);
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(vault.totalAssets(), 0);
        assertEq(asset.balanceOf(user), _amount);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
    }

    function test_rebalance(uint256 _amount, uint256 _minimumBuffer) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        _minimumBuffer = bound(_minimumBuffer, 10, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        vm.prank(governator);
        mockEscrow.updateMinimumBuffer(_minimumBuffer);

        uint256 left = _amount > _minimumBuffer ? _amount - _minimumBuffer : 0;

        mockEscrow.rebalance();

        assertEq(vault.totalAssets(), left);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), _amount - left);
        assertEq(vault.balanceOf(address(mockEscrow)), left);

        vm.prank(governator);
        mockEscrow.updateMinimumBuffer(0);

        mockEscrow.rebalance();

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);
    }

    function test_bridgeAsset_updateVault(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        IVault newVault = deployMockVault();

        // Migrate funds to the new vault.
        vm.expectRevert();
        mockEscrow.updateVault(address(newVault));

        vm.prank(governator);
        mockEscrow.updateVault(address(newVault));

        assertEq(vault.totalAssets(), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
        assertEq(asset.allowance(address(mockEscrow), address(vault)), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(newVault.totalAssets(), _amount);
        assertEq(newVault.balanceOf(address(mockEscrow)), _amount);
        assertEq(
            asset.allowance(address(mockEscrow), address(newVault)),
            2 ** 256 - 1
        );

        // Bridge again to cause deposit
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), 0);
        assertEq(newVault.totalAssets(), _amount * 2);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
        assertEq(newVault.balanceOf(address(mockEscrow)), _amount * 2);

        // Withdraw everything
        bytes memory data = abi.encode(user, _amount * 2);
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(newVault.totalAssets(), 0);
        assertEq(asset.balanceOf(user), _amount * 2);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(newVault.balanceOf(address(mockEscrow)), 0);
    }

    function test_managerWithdraw(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        // Migrate funds to the new vault.
        vm.expectRevert();
        mockEscrow.withdraw(czar, _amount);

        vm.expectRevert();
        vm.prank(czar);
        mockEscrow.withdraw(czar, _amount + 1);

        vm.prank(czar);
        mockEscrow.withdraw(czar, _amount);

        assertEq(vault.totalAssets(), _amount);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(czar), _amount);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);

        // Withdraw and donate underlying. should still be able to withdraw
        vm.prank(czar);
        vault.redeem(_amount, address(mockEscrow), czar);

        // Withdraw everything
        bytes memory data = abi.encode(user, _amount);
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        assertEq(vault.totalAssets(), 0);
        assertEq(asset.balanceOf(user), _amount);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
    }

    function test_illiquidWithdraw(uint256 _amount) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), _amount);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), _amount);

        // send funds to a strategy
        uint256 toLock = _amount / 2;
        addStrategyAndDebt(vault, setUpStrategy(), toLock);
        // And remove from queue
        address[] memory queue = new address[](0);
        vm.prank(governator);
        vault.set_default_queue(queue);

        assertEq(vault.maxWithdraw(address(mockEscrow)), _amount - toLock);

        // Withdraw everything
        bytes memory data = abi.encode(user, _amount);
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        // Should have sent the liquid balance and the rest in shares
        assertEq(vault.totalAssets(), toLock);
        assertEq(asset.balanceOf(user), _amount - toLock);
        assertEq(vault.balanceOf(user), toLock);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
    }

    function test_illiquidWithdraw_withBuffer(
        uint256 _amount,
        uint256 _minimumBuffer
    ) public {
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);
        _minimumBuffer = bound(_minimumBuffer, 10, _amount / 2);
        address counterPart = l1Deployer.getL2EscrowAddress(
            l2RollupID,
            address(asset)
        );

        mockEscrow = deployMockL1Escrow();

        vm.prank(governator);
        mockEscrow.updateMinimumBuffer(_minimumBuffer);

        // Simulate a bridge txn
        mintAndBridge(mockEscrow, user, _amount);

        assertEq(vault.totalAssets(), _amount - _minimumBuffer);
        assertEq(asset.balanceOf(user), 0);
        assertEq(asset.balanceOf(address(mockEscrow)), _minimumBuffer);
        assertEq(
            vault.balanceOf(address(mockEscrow)),
            _amount - _minimumBuffer
        );

        // send funds to a strategy
        uint256 toLock = _amount / 2;
        addStrategyAndDebt(vault, setUpStrategy(), toLock);
        // And remove from queue
        address[] memory queue = new address[](0);
        vm.prank(governator);
        vault.set_default_queue(queue);

        assertEq(
            vault.maxWithdraw(address(mockEscrow)),
            _amount - _minimumBuffer - toLock
        );

        // Withdraw everything
        bytes memory data = abi.encode(user, _amount);
        vm.prank(address(polygonZkEVMBridge));
        mockEscrow.onMessageReceived(counterPart, l2RollupID, data);

        // Should have sent the liquid balance and the rest in shares
        assertEq(vault.totalAssets(), toLock);
        assertEq(asset.balanceOf(user), _amount - toLock);
        assertEq(vault.balanceOf(user), toLock);
        assertEq(asset.balanceOf(address(mockEscrow)), 0);
        assertEq(vault.balanceOf(address(mockEscrow)), 0);
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

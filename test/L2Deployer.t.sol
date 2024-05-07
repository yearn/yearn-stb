// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {MockBridge} from "./mocks/MockBridge.sol";
import {Setup, console, L2Deployer, L1YearnEscrow, L2Token, L2Escrow, L2TokenConverter, IPolygonZkEVMBridge} from "./utils/Setup.sol";

contract L2DeployerTest is Setup {
    event NewToken(
        address indexed l1Token,
        address indexed l2Token,
        address indexed l2Escrow,
        address l2Converter
    );

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

    struct BridgeData {
        address l1Token;
        address l1Escrow;
        string name;
        string symbol;
    }

    L1YearnEscrow public mockEscrow;

    function setUp() public virtual override {
        // Use mock bridge.
        polygonZkEVMBridge = IPolygonZkEVMBridge(address(new MockBridge()));
        super.setUp();
        mockEscrow = deployMockL1Escrow();
    }

    // Deploy L2 Deployer using the mock bridge
    function deployL2Contracts() public override {
        l2TokenImpl = new L2Token();

        l2EscrowImpl = new L2Escrow();

        l2TokenConverterImpl = new L2TokenConverter();

        l2Deployer = new L2Deployer(
            l2Admin,
            address(l1Deployer),
            l2RiskManager,
            l2EscrowManager,
            address(polygonZkEVMBridge),
            address(l2TokenImpl),
            address(l2EscrowImpl),
            address(l2TokenConverterImpl)
        );
    }

    function test_transferAdmin() public {
        bytes32 L2_ADMIN = l2Deployer.L2_ADMIN();
        bytes32 PENDING_ADMIN = l2Deployer.PENDING_ADMIN();
        assertEq(l2Deployer.getPositionHolder(L2_ADMIN), l2Admin);
        assertEq(l2Deployer.getPositionHolder(PENDING_ADMIN), address(0));

        vm.expectRevert("!two step flow");
        vm.prank(l2Admin);
        l2Deployer.setPositionHolder(L2_ADMIN, user);

        vm.prank(l2Admin);
        l2Deployer.setPositionHolder(PENDING_ADMIN, user);

        assertEq(l2Deployer.getPositionHolder(L2_ADMIN), l2Admin);
        assertEq(l2Deployer.getPositionHolder(PENDING_ADMIN), user);

        vm.expectRevert();
        vm.prank(l2Admin);
        l2Deployer.acceptAdmin();

        vm.prank(user);
        l2Deployer.acceptAdmin();

        assertEq(l2Deployer.getPositionHolder(L2_ADMIN), user);
        assertEq(l2Deployer.getPositionHolder(PENDING_ADMIN), address(0));
    }

    function test_deployNewContract() public {
        address _asset = address(asset);
        bytes memory data = abi.encode(
            BridgeData({
                l1Token: address(asset),
                l1Escrow: address(mockEscrow),
                name: "Pretend Token",
                symbol: "ptTKN"
            })
        );

        address expectedTokenAddress = l1Deployer.getL2TokenAddress(_asset);
        address expectedEscrowAddress = l1Deployer.getL2EscrowAddress(_asset);
        address expectedConverterAddress = l1Deployer.getL2ConverterAddress(
            _asset
        );

        vm.expectRevert("L2Deployer: Not PolygonZkEVMBridge");
        l2Deployer.onMessageReceived(address(l1Deployer), l1RollupID, data);

        vm.expectRevert("L2Deployer: Not counterpart contract");
        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(user, l1RollupID, data);

        vm.expectRevert("L2Deployer: Not counterpart network");
        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(address(l1Deployer), l2RollupID, data);

        vm.expectEmit(true, true, true, true, address(l2Deployer));
        emit NewToken(
            _asset,
            expectedTokenAddress,
            expectedEscrowAddress,
            expectedConverterAddress
        );
        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(address(l1Deployer), l1RollupID, data);

        address[] memory assets = l2Deployer.getAllBridgedAssets();

        assertEq(assets.length, 1);
        assertEq(assets[0], _asset);

        (
            address _l2Token,
            address _l1Escrow,
            address _l2Escrow,
            address _l2Converter
        ) = l2Deployer.tokenInfo(_asset);
        assertEq(_l2Token, expectedTokenAddress);
        assertEq(_l1Escrow, address(mockEscrow));
        assertEq(_l2Escrow, expectedEscrowAddress);
        assertEq(_l2Converter, expectedConverterAddress);
    }

    function test_l2TokenSetup() public {
        bytes memory data = abi.encode(
            BridgeData({
                l1Token: address(asset),
                l1Escrow: address(mockEscrow),
                name: "Pretend Token",
                symbol: "ptTKN"
            })
        );

        address expectedTokenAddress = l1Deployer.getL2TokenAddress(
            address(asset)
        );

        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(address(l1Deployer), l1RollupID, data);

        (
            address _l2Token,
            address _l1Escrow,
            address _l2Escrow,
            address _l2Converter
        ) = l2Deployer.tokenInfo(address(asset));
        assertEq(_l2Token, expectedTokenAddress);

        L2Token token = L2Token(_l2Token);

        assertEq(token.owner(), l2Admin);
        assertEq(token.name(), "Pretend Token");
        assertEq(token.symbol(), "ptTKN");
        assertEq(token.totalSupply(), 0);

        vm.expectRevert();
        token.pause();
        vm.prank(l2Admin);
        token.pause();

        vm.expectRevert();
        token.unpause();
        vm.prank(l2Admin);
        token.unpause();

        uint256 amount = 1e18;

        vm.expectRevert();
        vm.prank(l2Admin);
        token.bridgeMint(user, amount);

        vm.prank(_l2Escrow);
        token.bridgeMint(user, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(user), amount);

        vm.prank(_l2Converter);
        token.converterMint(user, amount);

        assertEq(token.totalSupply(), amount * 2);
        assertEq(token.balanceOf(user), amount * 2);

        vm.prank(_l2Converter);
        token.converterBurn(user, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(user), amount);

        vm.prank(_l2Escrow);
        token.bridgeBurn(user, amount);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(user), 0);
    }

    function test_l2EscrowSetup() public {
        // Use mock bridge
        bytes memory data = abi.encode(
            BridgeData({
                l1Token: address(asset),
                l1Escrow: address(mockEscrow),
                name: "Pretend Token",
                symbol: "ptTKN"
            })
        );

        address expectedEscrowAddress = l1Deployer.getL2EscrowAddress(
            address(asset)
        );

        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(address(l1Deployer), l1RollupID, data);

        (address _l2Token, , address _l2Escrow, ) = l2Deployer.tokenInfo(
            address(asset)
        );
        assertEq(_l2Escrow, expectedEscrowAddress);

        L2Token token = L2Token(_l2Token);
        L2Escrow escrow = L2Escrow(_l2Escrow);

        assertEq(escrow.owner(), l2Admin);
        assertEq(escrow.polygonZkEVMBridge(), address(polygonZkEVMBridge));
        assertEq(escrow.counterpartContract(), address(mockEscrow));
        assertEq(escrow.counterpartNetwork(), l1RollupID);
        assertEq(escrow.originTokenAddress(), address(asset));
        assertEq(address(escrow.wrappedTokenAddress()), _l2Token);

        uint256 amount = 1e18;

        data = abi.encode(user, amount);

        vm.expectRevert();
        escrow.onMessageReceived(address(mockEscrow), l1RollupID, data);

        vm.prank(address(polygonZkEVMBridge));
        escrow.onMessageReceived(address(mockEscrow), l1RollupID, data);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(user), amount);

        // Allow the L1 escrow to service the withdraw
        airdrop(asset, address(mockEscrow), amount);

        vm.expectRevert();
        escrow.bridgeToken(user, amount, true);

        uint256 depositCount = polygonZkEVMBridge.depositCount();
        vm.expectEmit(true, true, true, true, address(polygonZkEVMBridge));
        emit BridgeEvent(
            1,
            l2RollupID,
            address(escrow),
            l1RollupID,
            address(mockEscrow),
            0,
            data,
            uint32(depositCount)
        );
        vm.prank(user);
        escrow.bridgeToken(user, amount, true);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(user), 0);
    }

    function test_l2EConverterSetup() public {
        // Use mock bridge
        bytes memory data = abi.encode(
            BridgeData({
                l1Token: address(asset),
                l1Escrow: address(mockEscrow),
                name: "Pretend Token",
                symbol: "ptTKN"
            })
        );

        address expectedConverterAddress = l1Deployer.getL2ConverterAddress(
            address(asset)
        );

        vm.prank(address(polygonZkEVMBridge));
        l2Deployer.onMessageReceived(address(l1Deployer), l1RollupID, data);

        (
            address _l2Token,
            ,
            address _l2Escrow,
            address _l2Converter
        ) = l2Deployer.tokenInfo(address(asset));
        assertEq(_l2Converter, expectedConverterAddress);

        L2Token token = L2Token(_l2Token);
        L2Escrow escrow = L2Escrow(_l2Escrow);
        L2TokenConverter converter = L2TokenConverter(_l2Converter);

        assertEq(converter.owner(), l2Admin);
    }
}

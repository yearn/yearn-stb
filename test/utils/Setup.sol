// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import "forge-std/console.sol";
import {ExtendedTest} from "./ExtendedTest.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Roles} from "@yearn-vaults/interfaces/Roles.sol";
import {IVault} from "@yearn-vaults/interfaces/IVault.sol";
import {IStrategy} from "../../src/interfaces/Yearn/IStrategy.sol";
import {IVaultFactory} from "@yearn-vaults/interfaces/IVaultFactory.sol";

import {Registry, RegistryFactory} from "@vault-periphery/registry/RegistryFactory.sol";
import {DebtAllocator, DebtAllocatorFactory} from "@vault-periphery/debtAllocators/DebtAllocatorFactory.sol";

import {ICREATE3Factory} from "../../src/interfaces/ICREATE3Factory.sol";

import {IPolygonZkEVMBridge} from "../../src/interfaces/Polygon/IPolygonZkEVMBridge.sol";

import {IAccountant} from "../../src/interfaces/Yearn/IAccountant.sol";
import {IAccountantFactory} from "../../src/interfaces/Yearn/IAccountantFactory.sol";

import {L1Deployer} from "../../src/L1Deployer.sol";
import {L2Deployer} from "../../src/L2Deployer.sol";
import {L1YearnEscrow} from "../../src/L1YearnEscrow.sol";

import {Proxy} from "@zkevm-stb/Proxy.sol";
import {L2Escrow} from "@zkevm-stb/L2Escrow.sol";
import {L2Token} from "@zkevm-stb/L2Token.sol";
import {L2TokenConverter} from "@zkevm-stb/L2TokenConverter.sol";

import {MockTokenizedStrategy} from "../mocks/MockTokenizedStrategy.sol";

contract Setup is ExtendedTest {
    using SafeERC20 for ERC20;

    // Contract instances that we will use repeatedly.
    ERC20 public asset;

    IPolygonZkEVMBridge public polygonZkEVMBridge =
        IPolygonZkEVMBridge(0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe);

    address public rollupManager = 0x5132A183E9F3CB7C848b0AAC5Ae0c4f0491B7aB2;

    ICREATE3Factory internal constant create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    // Vault contracts to test with.
    IVault public vault;
    // Vault Factory v3.0.2
    IVaultFactory public vaultFactory =
        IVaultFactory(0x444045c5C13C246e117eD36437303cac8E250aB0);

    /// Periphery Contracts \\\

    Registry public registry;
    RegistryFactory public registryFactory =
        RegistryFactory(0x8648FF16ed48FAD456BF0e0e2190AeA8710BdC81);

    DebtAllocatorFactory public allocatorFactory;

    IAccountant public accountant;
    IAccountantFactory public accountantFactory =
        IAccountantFactory(0xF728f839796a399ACc2823c1e5591F05a31c32d1);

    /// Core Contracts \\\\

    ///// L1 Contracts \\\\\
    L1Deployer public l1Deployer;

    L1YearnEscrow public l1EscrowImpl;

    //// L2 Contracts \\\\\

    L2Deployer public l2Deployer;

    L2Escrow public l2EscrowImpl;

    L2Token public l2TokenImpl;

    L2TokenConverter public l2TokenConverterImpl;

    // Addresses for different roles we will use repeatedly.
    address public czar = address(1);
    address public user = address(2);
    address public keeper = address(3);
    address public l2Admin = address(70);
    address public management = address(4);
    address public governator = address(69);
    address public feeRecipient = address(5);
    address public emergencyAdmin = address(6);
    address public l2RiskManager = address(48);
    address public l2EscrowManager = address(67);

    mapping(string => address) public tokenAddrs;

    // Integer variables that will be used repeatedly.
    uint256 public decimals;
    uint256 public MAX_BPS = 10_000;
    uint256 public WAD = 1e18;

    // Fuzz amount
    uint256 public maxFuzzAmount = 1e30;
    uint256 public minFuzzAmount = 1e4;

    // Default profit max unlock time is set for 10 days
    uint256 public profitMaxUnlockTime = 10 days;

    uint32 public l1RollupID = 0;
    uint32 public l2RollupID = 1;

    function setUp() public virtual {
        _setTokenAddrs();

        // Deploy new Registry.
        registry = Registry(
            registryFactory.createNewRegistry("Test STB Registry", governator)
        );

        // Deploy new Debt Allocator Factory.
        allocatorFactory = DebtAllocatorFactory(
            new DebtAllocatorFactory(governator)
        );

        // Deploy new Accountant
        accountant = IAccountant(
            accountantFactory.newAccountant(
                governator, // governance
                feeRecipient, // Fee recipient
                0, // Management Fee
                1_000, // Perf Fee
                0, // Refund Ratio
                10_000, // Max Fee
                20_000, // Max Gain
                0 // Max Loss
            )
        );

        l1EscrowImpl = new L1YearnEscrow();

        l1Deployer = new L1Deployer(
            governator,
            czar,
            management,
            emergencyAdmin,
            keeper,
            address(registry),
            address(allocatorFactory),
            address(polygonZkEVMBridge),
            address(0),
            address(l1EscrowImpl)
        );

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

        vm.startPrank(governator);
        registry.setEndorser(address(l1Deployer), true);
        l1Deployer.setPositionHolder(
            l1Deployer.ACCOUNTANT(),
            address(accountant)
        );
        accountant.setVaultManager(address(l1Deployer));
        l1Deployer.setPositionHolder(
            l1Deployer.L2_DEPLOYER(),
            address(l2Deployer)
        );
        vm.stopPrank();

        // Make sure everything works with USDT
        asset = ERC20(tokenAddrs["DAI"]);

        // Set decimals
        decimals = asset.decimals();

        // label all the used addresses for traces

        vm.label(czar, "czar");
        vm.label(keeper, "keeper");
        vm.label(address(vault), "vault");
        vm.label(address(asset), "asset");
        vm.label(management, "management");
        vm.label(governator, "governator");
        vm.label(feeRecipient, "feeRecipient");
        vm.label(address(registry), "Registry");
        vm.label(address(accountant), "Accountant");
        vm.label(address(l1Deployer), "L1 Deployer");
        vm.label(address(l2Deployer), "L2 Deployer");
        vm.label(address(l2TokenImpl), "L2 Token Impl");
        vm.label(address(l2EscrowImpl), "L2 Escrow IMPL");
        vm.label(address(l1EscrowImpl), "L1 escrow IMPL");
        vm.label(address(vaultFactory), " vault factory");
        vm.label(address(create3Factory), "Create 3 Factory");
        vm.label(address(polygonZkEVMBridge), "Polygon Bridge");
        vm.label(address(allocatorFactory), "Allocator Factory");
        vm.label(address(l2TokenConverterImpl), "L2 Converter IMPL");
    }

    function deployMockVault() public returns (IVault _newVault) {
        // Skip 1 to always get a unique name each time
        skip(1);
        _newVault = IVault(
            vaultFactory.deploy_new_vault(
                address(asset),
                string.concat(
                    "Mock Vault",
                    string(abi.encode(block.timestamp))
                ),
                "yvMock",
                governator,
                10 days
            )
        );

        vm.startPrank(governator);
        _newVault.set_role(governator, Roles.ALL);
        _newVault.set_deposit_limit(2 ** 256 - 1);
        vm.stopPrank();
    }

    function setUpStrategy() public returns (IStrategy) {
        // we save the strategy as a IStrategyInterface to give it the needed interface
        IStrategy _strategy = IStrategy(
            address(new MockTokenizedStrategy(address(asset)))
        );

        // set keeper
        _strategy.setKeeper(keeper);
        // set treasury
        _strategy.setPerformanceFeeRecipient(feeRecipient);
        // set management of the strategy
        _strategy.setPendingManagement(management);
        // Accept management.
        vm.prank(management);
        _strategy.acceptManagement();

        return _strategy;
    }

    function deployMockL1Escrow() internal returns (L1YearnEscrow newEscrow) {
        bytes memory data = abi.encodeCall(
            L1YearnEscrow.initialize,
            (
                governator,
                czar,
                address(polygonZkEVMBridge),
                getL2EscrowAddress(address(asset)),
                l2RollupID,
                address(asset),
                getL2TokenAddress(address(asset)),
                address(vault)
            )
        );

        newEscrow = L1YearnEscrow(
            _create3Deploy(
                keccak256(abi.encodePacked(bytes("L1Escrow:"), address(asset))),
                address(l1EscrowImpl),
                data
            )
        );
    }

    function bridgeAsset(
        L1YearnEscrow _escrow,
        address _user,
        uint256 _amount
    ) public {
        vm.startPrank(_user);
        asset.approve(address(_escrow), _amount);

        _escrow.bridgeToken(_user, _amount, true);
        vm.stopPrank();
    }

    function mintAndBridge(
        L1YearnEscrow _escrow,
        address _user,
        uint256 _amount
    ) public {
        airdrop(asset, _user, _amount);
        bridgeAsset(_escrow, _user, _amount);
    }

    function addStrategyToVault(IVault _vault, IStrategy _strategy) public {
        vm.prank(governator);
        _vault.add_strategy(address(_strategy));

        vm.prank(governator);
        _vault.update_max_debt_for_strategy(
            address(_strategy),
            type(uint256).max
        );
    }

    function addDebtToStrategy(
        IVault _vault,
        IStrategy _strategy,
        uint256 _amount
    ) public {
        vm.prank(governator);
        _vault.update_debt(address(_strategy), _amount);
    }

    function addStrategyAndDebt(
        IVault _vault,
        IStrategy _strategy,
        uint256 _amount
    ) public {
        addStrategyToVault(_vault, _strategy);
        addDebtToStrategy(_vault, _strategy, _amount);
    }

    function airdrop(ERC20 _asset, address _to, uint256 _amount) public {
        uint256 balanceBefore = _asset.balanceOf(_to);
        deal(address(_asset), _to, balanceBefore + _amount);
    }

    function getL2TokenAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                address(l2Deployer),
                keccak256(abi.encodePacked(bytes("L2Token:"), _l1TokenAddress))
            );
    }

    function getL1EscrowAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                address(l1Deployer),
                keccak256(abi.encodePacked(bytes("L1Escrow:"), _l1TokenAddress))
            );
    }

    function getL2EscrowAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                address(l2Deployer),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _l1TokenAddress))
            );
    }

    function getL2ConverterAddress(
        address _l1TokenAddress
    ) public view virtual returns (address) {
        return
            create3Factory.getDeployed(
                address(l2Deployer),
                keccak256(
                    abi.encodePacked(
                        bytes("L2TokenConverter:"),
                        _l1TokenAddress
                    )
                )
            );
    }

    function _create3Deploy(
        bytes32 _salt,
        address _implementation,
        bytes memory _initData
    ) internal returns (address) {
        bytes memory _creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(_implementation, _initData)
        );

        return create3Factory.deploy(_salt, _creationCode);
    }

    function _setTokenAddrs() internal {
        tokenAddrs["WBTC"] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        tokenAddrs["YFI"] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
        tokenAddrs["WETH"] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        tokenAddrs["LINK"] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        tokenAddrs["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokenAddrs["DAI"] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        tokenAddrs["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }
}

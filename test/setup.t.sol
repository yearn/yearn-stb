// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {Setup, console} from "./utils/Setup.sol";

contract SetupTest is Setup {
    
    function setUp() public virtual override{
        super.setUp();
    }


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
        bytes memory symbol = bytes(asset.symbol());
        string memory made = string.concat(string(symbol), ".e");
        console.log("Symbol ", made);   
        assert(false);
    }

    function test_newVault() public {
        // Pretend to be the rollup 1
        uint32 rollupID = 1;
        address rollupContract = 0x519E42c24163192Dca44CD3fBDCEBF6be9130987;
        address admin = 0x242daE44F5d8fb54B198D03a94dA45B5a4413e21;
        address manager = address(123);

        vm.expectRevert("!admin");
        l1Deployer.registerRollup(rollupID, manager); 

        vm.prank(admin);
        l1Deployer.registerRollup(rollupID, manager);

        l1Deployer.newAsset(rollupID, address(asset));
    }
}
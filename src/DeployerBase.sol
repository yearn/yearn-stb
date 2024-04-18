// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeployerBase {
    ICREATE3Factory internal constant create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    address public immutable counterPartContract;

    address public immutable polygonZkEVMBridge;

    constructor(address _counterPartContract, address _polygonZkEVMBridge) {
        counterPartContract = _counterPartContract;
        polygonZkEVMBridge = _polygonZkEVMBridge;
    }
}

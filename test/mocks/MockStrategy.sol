// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {ERC4626Mock} from "@openzeppelin/contracts/mocks/token/ERC4626Mock.sol";

contract MockStrategy is ERC4626Mock {
    constructor(address _asset) ERC4626Mock(_asset) {}
}

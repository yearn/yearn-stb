// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {BaseStrategy, ERC20} from "./BaseStrategy.sol";

contract MockTokenizedStrategy is BaseStrategy {
    constructor(
        address _asset,
        string memory _name
    ) BaseStrategy(_asset, _name) {}

    function _deployFunds(uint256 _amount) internal virtual override {}

    function _freeFunds(uint256 _amount) internal virtual override {}

    function _harvestAndReport() internal virtual override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}

contract MockTokenized is MockTokenizedStrategy {
    uint256 public loss;
    uint256 public limit;

    constructor(
        address _asset,
        string memory _name
    ) MockTokenizedStrategy(_asset, _name) {}

    function realizeLoss(uint256 _amount) external {
        asset.transfer(msg.sender, _amount);
    }

    function availableWithdrawLimit(
        address _owner
    ) public view virtual override returns (uint256) {
        if (limit != 0) {
            uint256 _totalAssets = TokenizedStrategy.totalAssets();
            return _totalAssets > limit ? _totalAssets - limit : 0;
        } else {
            return super.availableWithdrawLimit(_owner);
        }
    }

    function setLimit(uint256 _limit) external {
        limit = _limit;
    }
}

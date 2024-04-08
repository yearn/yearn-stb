// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {TokenizedStrategy, ERC20} from "@tokenized-strategy/TokenizedStrategy.sol";

contract MockTokenizedStrategy is TokenizedStrategy {

    constructor(
        address _factory,
        address _asset,
        string memory _name,
        address _management,
        address _keeper
    ) TokenizedStrategy(_factory) {
        // Cache storage pointer
        StrategyData storage S = _strategyStorage();

        // Set the strategy's underlying asset
        S.asset = ERC20(_asset);
        // Set the Strategy Tokens name.
        S.name = _name;
        // Set decimals based off the `asset`.
        S.decimals = ERC20(_asset).decimals();

        // Set last report to this block.
        S.lastReport = uint96(block.timestamp);

        // Set the default management address. Can't be 0.
        require(_management != address(0), "ZERO ADDRESS");
        S.management = _management;
        S.performanceFeeRecipient = _management;
        // Set the keeper address
        S.keeper = _keeper;
    }

    function availableWithdrawLimit(
        address /*_owner*/
    ) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function deployFunds(uint256 _amount) external virtual {}

    function freeFunds(uint256 _amount) external virtual {}

    function harvestAndReport() external virtual returns (uint256) {
        return _strategyStorage().asset.balanceOf(address(this));
    }
}

contract MockTokenized is MockTokenizedStrategy {
    uint256 public loss;
    uint256 public limit;

    constructor(
        address _factory,
        address _asset,
        string memory _name,
        address _management,
        address _keeper
    ) MockTokenizedStrategy(_factory, _asset, _name, _management, _keeper) {
    }

    function realizeLoss(uint256 _amount) external {
        _strategyStorage().asset.transfer(msg.sender, _amount);
    }

    function availableWithdrawLimit(
        address _owner
    ) public view virtual override returns (uint256) {
        if (limit != 0) {
            uint256 _totalAssets = _strategyStorage().totalAssets;
            return _totalAssets > limit ? _totalAssets - limit : 0;
        } else {
            return super.availableWithdrawLimit(_owner);
        }
    }

    function setLimit(uint256 _limit) external {
        limit = _limit;
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L1YearnEscrow} from "../L1YearnEscrow.sol";
import {L1Deployer} from "../L1Deployer.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Multicall} from "./Multicall.sol";
import {PeripheryPayments} from "./PeripheryPayments.sol";

import {IPermit2} from "./IPermit2.sol";

contract STBRouter is Multicall, PeripheryPayments {
    using SafeERC20 for ERC20;

    // The canonical permit2 contract.
    IPermit2 public immutable PERMIT2;

    L1Deployer public immutable l1Deployer;

    constructor(
        address weth,
        address _permit2,
        address _l1Deployer
    ) PeripheryPayments(weth) {
        PERMIT2 = IPermit2(_permit2);
        l1Deployer = L1Deployer(_l1Deployer);
    }

    // Getter function to unpack stored name.
    function name() external pure returns (string memory) {
        return "Stake The Bridge Router";
    }

    function bridge(uint32 _rollupID, address _asset) external virtual {
        bridge(
            _rollupID,
            _asset,
            ERC20(_asset).balanceOf(msg.sender),
            msg.sender
        );
    }

    function bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount
    ) external virtual {
        bridge(_rollupID, _asset, _amount, msg.sender);
    }

    function bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver
    ) public virtual {
        pullToken(ERC20(_asset), _amount, address(this));
        _bridge(_rollupID, _asset, _amount, _receiver);
    }

    function bridgePermit2(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver,
        uint256 _nonce,
        uint256 _deadline,
        bytes calldata _signature
    ) public virtual {
        // Transfer from using Permit2
        PERMIT2.permitTransferFrom(
            IPermit2.PermitTransferFrom({
                permitted: IPermit2.TokenPermissions({
                    token: _asset,
                    amount: _amount
                }),
                nonce: _nonce,
                deadline: _deadline
            }),
            IPermit2.SignatureTransferDetails({
                to: address(this),
                requestedAmount: _amount
            }),
            msg.sender,
            _signature
        );

        _bridge(_rollupID, _asset, _amount, _receiver);
    }

    function bridgeEth(
        uint32 _rollupID,
        address _asset,
        address _receiver
    ) public payable virtual {
        wrapWETH9();
        uint256 _amount = WETH9.balanceOf(address(this));
        _bridge(_rollupID, _asset, _amount, _receiver);
    }

    function _bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver
    ) internal virtual {
        L1YearnEscrow escrow = L1YearnEscrow(
            l1Deployer.getEscrow(_rollupID, _asset)
        );

        escrow.bridgeToken(_receiver, _amount, true);
    }
}

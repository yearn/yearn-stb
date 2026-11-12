// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L1YearnEscrow} from "../L1YearnEscrow.sol";
import {L1Deployer} from "../L1Deployer.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Multicall} from "./Multicall.sol";
import {PeripheryPayments} from "./PeripheryPayments.sol";

import {IPermit2} from "./IPermit2.sol";

/// @notice Simple router for bridging to any L2's that use the LxLy Stake the Bridge implementation.
/// @dev Allows for multicall, native ETH and Permit2 bridging.
contract STBRouter is Multicall, PeripheryPayments {
    using SafeERC20 for ERC20;

    /// @notice The canonical permit2 contract.
    IPermit2 public immutable PERMIT2;

    /// @notice The L1 Deployer for Polygon's LxLy Escrows.
    L1Deployer public immutable L1DEPLOYER;

    constructor(
        address weth,
        address _permit2,
        address _l1Deployer
    ) PeripheryPayments(weth) {
        PERMIT2 = IPermit2(_permit2);
        L1DEPLOYER = L1Deployer(_l1Deployer);
    }

    /**
     * @notice Name of the contract
     */
    function name() external pure returns (string memory) {
        return "Stake The Bridge Router";
    }

    /**
     * @notice Bridge all of token to a L2.
     * @dev Default to msg sender for receiver and the full balance as amount.
     * @param _rollupID The Polygon Rollup ID to bridge to.
     * @param _asset Token to bridge.
     */
    function bridge(uint32 _rollupID, address _asset) external virtual {
        _bridge(
            _rollupID,
            _asset,
            ERC20(_asset).balanceOf(msg.sender),
            msg.sender
        );
    }

    /**
     * @notice Bridge a token to a L2.
     * @dev Defaults to msg.sender as the receiver.
     * @param _rollupID The Polygon Rollup ID to bridge to.
     * @param _asset Token to bridge.
     * @param _amount The amount of `_asset` to bridge.
     */
    function bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount
    ) external virtual {
        _bridge(_rollupID, _asset, _amount, msg.sender);
    }

    /**
     * @notice Bridge a token to a L2.
     * @param _rollupID The Polygon Rollup ID to bridge to.
     * @param _asset Token to bridge.
     * @param _amount The amount of `_asset` to bridge.
     * @param _receiver The address to receive the tokens on the L2.
     */
    function bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver
    ) public virtual {
        _bridge(_rollupID, _asset, _amount, _receiver);
    }

    /**
     * @notice Bridge a token to a L2 using Permit2.
     * @dev Requires an off chain signature and the sender to have approved Permit2.
     * @param _rollupID The Polygon Rollup ID to bridge to.
     * @param _asset Token to bridge
     * @param _amount The amount of `_asset` to bridge.
     * @param _receiver The address to receive the tokens on the L2.
     * @param _nonce The unique nonce for Permit2 to use.
     * @param _deadline Timestamp the signature is good till.
     * @param _signature Off chain Permit2 signature signed by msg.sender.
     */
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

        _bridgeToken(_rollupID, _asset, _amount, _receiver);
    }

    /**
     * @notice Bridge WETH to a L2 using native ETH.
     * @dev The amount used will be the msg.value.
     * @param _rollupID The Polygon Rollup ID to bridge to.
     * @param _receiver The address to receive the tokens on the L2.
     */
    function bridgeEth(
        uint32 _rollupID,
        address _receiver
    ) public payable virtual {
        wrapWETH9();
        uint256 _amount = WETH9.balanceOf(address(this));
        _bridgeToken(_rollupID, address(WETH9), _amount, _receiver);
    }

    /**
     * @dev Pulls the token from the caller and bridges.
     *   Requires that approval to this contract has been given.
     *   AND that approval has been granted for the escrow to pull
     *   `_asset` from this contract.
     */
    function _bridge(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver
    ) internal virtual {
        pullToken(ERC20(_asset), _amount, address(this));
        _bridgeToken(_rollupID, _asset, _amount, _receiver);
    }

    /**
     * @dev Retrieves the escrow from the L1 Deployer and bridges to the L2.
     *   Will revert if no escrow has been deployed yet.
     */
    function _bridgeToken(
        uint32 _rollupID,
        address _asset,
        uint256 _amount,
        address _receiver
    ) internal virtual {
        L1YearnEscrow escrow = L1YearnEscrow(
            L1DEPLOYER.getEscrow(_rollupID, _asset)
        );

        escrow.bridgeToken(_receiver, _amount, true);
    }
}

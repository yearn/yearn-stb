// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L2Token} from "@zkevm-stb/L2Token.sol";
import {DeployerBase} from "./DeployerBase.sol";
import {L2Escrow} from "@zkevm-stb/L2Escrow.sol";
import {L2TokenConverter} from "@zkevm-stb/L2TokenConverter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Polygon CDK Stake the Bridge L2 Deployer.
contract L2Deployer is DeployerBase {
    event NewToken(
        address indexed l1Token,
        address indexed l2Token,
        address indexed l2Escrow,
        address l2Converter
    );

    struct TokenInfo {
        address l2Token;
        address l1Escrow;
        address l2Escrow;
        address l2Converter;
    }

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant L2_ADMIN = keccak256("L2 Admin");
    bytes32 public constant RISK_MANAGER = keccak256("Risk Manager");
    bytes32 public constant PENDING_ADMIN = keccak256("Pending Admin");
    bytes32 public constant ESCROW_MANAGER = keccak256("Escrow Manager");
    bytes32 public constant TOKEN_IMPLEMENTATION =
        keccak256("Token Implementation");
    bytes32 public constant CONVERTER_IMPLEMENTATION =
        keccak256("Converter Implementation");

    // Array of all L1 tokens that have a bridged version.
    address[] public bridgedAssets;

    // L1 Address => struct
    mapping(address => TokenInfo) public tokenInfo;

    constructor(
        address _l2Admin,
        address _l1Deployer,
        address _riskManager,
        address _escrowManager,
        address _polygonZkEVMBridge
    ) DeployerBase(_polygonZkEVMBridge, _l1Deployer, address(new L2Escrow())) {
        _setPositionHolder(L2_ADMIN, _l2Admin);
        _setPositionHolder(RISK_MANAGER, _riskManager);
        _setPositionHolder(ESCROW_MANAGER, _escrowManager);
        _setPositionHolder(TOKEN_IMPLEMENTATION, address(new L2Token()));
        _setPositionHolder(
            CONVERTER_IMPLEMENTATION,
            address(new L2TokenConverter())
        );
    }

    /**
     * @notice Get the name of this contract.
     */
    function name() external view virtual returns (string memory) {
        return "L2 Stake the Bridge Deployer";
    }

    /**
     * @notice Function triggered by the bridge once a message is received by the other network
     * @param originAddress Origin address that the message was sended
     * @param originNetwork Origin network that the message was sended ( not usefull for this contract)
     * @param data Abi encoded metadata
     */
    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable {
        // Can only be called by the bridge
        require(
            address(polygonZkEVMBridge) == msg.sender,
            "L2Deployer: Not PolygonZkEVMBridge"
        );
        require(
            getPositionHolder(L1_DEPLOYER) == originAddress,
            "L2Deployer: Not counterpart contract"
        );
        require(
            ORIGIN_NETWORK_ID == originNetwork,
            "L2Deployer: Not counterpart network"
        );

        _onMessageReceived(data);
    }

    /**
     * @notice Internal function triggered when receive a message
     * @param data message data containing the destination address and the token amount
     */
    function _onMessageReceived(bytes memory data) internal {
        // Decode message data
        BridgeData memory bridgeData = abi.decode(data, (BridgeData));

        // Get addresses
<<<<<<< HEAD
        address expectedTokenAddress = getL2TokenAddress(bridgeData.l1Token);
        address expectedEscrowAddress = getL2EscrowAddress(bridgeData.l1Token);
        address expectedConverterAddress = getL2ConverterAddress(
            bridgeData.l1Token
=======
        address expectedTokenAddress = getL2TokenAddress(
            ORIGIN_NETWORK_ID,
            _l1Token
        );
        address expectedEscrowAddress = getL2EscrowAddress(
            ORIGIN_NETWORK_ID,
            _l1Token
        );
        address expectedConverterAddress = getL2ConverterAddress(
            ORIGIN_NETWORK_ID,
            _l1Token
>>>>>>> feat: non deterministic
        );

        // Deploy Token
        address _l2Token = _deployL2Token(
            bridgeData.name,
            bridgeData.symbol,
            bridgeData.l1Token,
            expectedEscrowAddress,
            expectedConverterAddress
        );
        require(_l2Token == expectedTokenAddress, "wrong address");

        // Deploy escrow
        address _l2Escrow = _deployL2Escrow(
            bridgeData.l1Token,
            _l2Token,
            bridgeData.l1Escrow
        );
        require(_l2Escrow == expectedEscrowAddress, "wrong address");

        // Deploy Converter
        address _l2Converter = _deployL2Converter(bridgeData.l1Token, _l2Token);
        require(_l2Converter == expectedConverterAddress, "wrong address");

        // Store Data
        tokenInfo[bridgeData.l1Token] = TokenInfo({
            l2Token: _l2Token,
            l1Escrow: bridgeData.l1Escrow,
            l2Escrow: _l2Escrow,
            l2Converter: _l2Converter
        });
        bridgedAssets.push(bridgeData.l1Token);

        emit NewToken(bridgeData.l1Token, _l2Token, _l2Escrow, _l2Converter);
    }

    /**
     * @dev Deploys the L2 token contract.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _l1Token The address of the corresponding L1 token.
     * @param _l2Escrow The address of the L2 escrow contract.
     * @param _l2Converter The address of the L2 token converter contract.
     * @return The address of the deployed L2 token contract.
     */
    function _deployL2Token(
        string memory _name,
        string memory _symbol,
        address _l1Token,
        address _l2Escrow,
        address _l2Converter
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2Token.initialize,
            (
                getPositionHolder(L2_ADMIN),
                _l2Escrow,
                _l2Converter,
                _name,
                _symbol
            )
        );

        return
            _create3Deploy(
                keccak256(abi.encodePacked(bytes("L2Token:"), _l1Token)),
                getPositionHolder(TOKEN_IMPLEMENTATION),
                data
            );
    }

    /**
     * @dev Deploys an L2 escrow contract.
     * @param _l1Token The address of the corresponding L1 token.
     * @param _l2TokenAddress The address of the corresponding L2 token.
     * @param _l1Escrow The address of the corresponding L1 escrow contract.
     * @return The address of the deployed L2 escrow contract.
     */
    function _deployL2Escrow(
        address _l1Token,
        address _l2TokenAddress,
        address _l1Escrow
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2Escrow.initialize,
            (
                getPositionHolder(L2_ADMIN),
                address(polygonZkEVMBridge),
                _l1Escrow,
                ORIGIN_NETWORK_ID,
                _l1Token,
                _l2TokenAddress
            )
        );

        return
            _create3Deploy(
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _l1Token)),
                getPositionHolder(ESCROW_IMPLEMENTATION),
                data
            );
    }

    /**
     * @dev Deploys an L2 token converter contract.
     * @param _l1Token The address of the corresponding L1 token.
     * @param _l2Token The address of the corresponding L2 token.
     * @return The address of the deployed L2 token converter contract.
     */
    function _deployL2Converter(
        address _l1Token,
        address _l2Token
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2TokenConverter.initialize,
            (
                getPositionHolder(L2_ADMIN),
                getPositionHolder(ESCROW_MANAGER),
                getPositionHolder(RISK_MANAGER),
                _l2Token
            )
        );

        return
            _create3Deploy(
                keccak256(
                    abi.encodePacked(bytes("L2TokenConverter:"), _l1Token)
                ),
                getPositionHolder(CONVERTER_IMPLEMENTATION),
                data
            );
    }

    /**
     * @notice Setter function for updating a positions holder.
     * @dev Updating `L2 Admin` requires setting `PENDING_ADMIN`
     *  and then the pending address calling {acceptAdmin}.
     * @param _position Identifier for the position.
     * @param _newHolder New address for position.
     */
    function setPositionHolder(
        bytes32 _position,
        address _newHolder
    ) external virtual onlyPositionHolder(L2_ADMIN) {
        require(_position != L2_ADMIN, "!two step flow");
        _setPositionHolder(_position, _newHolder);
    }

    /**
     * @notice Accept the Governator role.
     * @dev Caller must be the Pending Governator.
     */
    function acceptAdmin() external virtual onlyPositionHolder(PENDING_ADMIN) {
        _setPositionHolder(L2_ADMIN, msg.sender);
        _setPositionHolder(PENDING_ADMIN, address(0));
    }

    /**
     * @notice Get the full list of all assets that have been bridged through this deployer.
     */
    function getAllBridgedAssets()
        external
        view
        virtual
        returns (address[] memory)
    {
        return bridgedAssets;
    }

    /**
     * @notice Get the :2 Deployer for a specific rollup.
     * @return The L2 Deployer address.
     */
    function getL2Deployer(
        uint32 /*_rollupID*/
    ) public view virtual override returns (address) {
        return address(this);
    }
}

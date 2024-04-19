// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {L2Escrow} from "@zkevm-stb/L2Escrow.sol";
import {L2Token} from "@zkevm-stb/L2Token.sol";
import {L2TokenConverter} from "@zkevm-stb/L2TokenConverter.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {DeployerBase} from "./DeployerBase.sol";

// Array of tokens?
// m
contract L2Deployer is DeployerBase {
    event NewToken(
        address indexed l1Token,
        address indexed l2Token,
        address indexed l2Escrow,
        address l2Convertor
    );

    struct TokenInfo {
        address l2Token;
        address l1Escrow;
        address l2Escrow;
        address l2Convertor;
    }

    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    address public l2Admin;

    address public l1Deployer;

    address public riskManager;

    address public escrowManager;

    address public tokenImplementation;

    address public escrowImplementation;

    address public convertorImplementation;

    // L1 Address => struct
    mapping(address => TokenInfo) public tokenInfo;

    constructor(
        address _l2Admin,
        address _l1Deployer,
        address _riskManager,
        address _escrowManager,
        address _polygonZkEVMBridge,
        address _tokenImplementation,
        address _escrowImplementation,
        address _convertorImplementation
    ) DeployerBase(_polygonZkEVMBridge) {
        l2Admin = _l2Admin;
        l1Deployer = _l1Deployer;
        riskManager = _riskManager;
        escrowManager = _escrowManager;
        tokenImplementation = _tokenImplementation;
        escrowImplementation = _escrowImplementation;
        convertorImplementation = _convertorImplementation;
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
            l1Deployer == originAddress,
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
        (
            address _l1Token,
            address _l1Escrow,
            string memory _name,
            bytes memory _symbol
        ) = abi.decode(data, (address, address, string, bytes));

        // Get addresses
        address expectedTokenAddress = _getL2TokenAddress(_symbol);
        address expectedEscrowAddress = _getL2EscrowAddress(_symbol);
        address expectedConvertorAddress = _getL2ConvertorAddress(_symbol);

        // Deploy Token
        address _l2Token = _deployL2Token(
            _name,
            _symbol,
            expectedEscrowAddress,
            expectedConvertorAddress
        );
        require(_l2Token == expectedTokenAddress, "wrong address");

        // Deploy escrow
        address _l2Escrow = _deployL2Escrow(
            _symbol,
            _l1Token,
            _l2Token,
            _l1Escrow
        );
        require(_l2Escrow == expectedEscrowAddress, "wrong address");

        // Deploy Convertor
        address _l2Convertor = _deployL2Convertor(_symbol, _l2Token);
        require(_l2Convertor == expectedConvertorAddress, "wrong address");

        // Store Data
        tokenInfo[_l1Token] = TokenInfo({
            l2Token: _l2Token,
            l1Escrow: _l1Escrow,
            l2Escrow: _l2Escrow,
            l2Convertor: _l2Convertor
        });

        emit NewToken(_l1Token, _l2Token, _l2Escrow, _l2Convertor);
    }

    function _deployL2Token(
        string memory _name,
        bytes memory _symbol,
        address _l2Escrow,
        address _l2Convertor
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2Token.initialize,
            (l2Admin, _l2Escrow, _l2Convertor, _name, string(_symbol))
        );

        return
            _create3Deploy(
                keccak256(abi.encodePacked(bytes("L2Token:"), _symbol)),
                tokenImplementation,
                data
            );
    }

    function _deployL2Escrow(
        bytes memory _symbol,
        address _l1Token,
        address _l2TokenAddress,
        address _l1Escrow
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2Escrow.initialize,
            (
                l2Admin,
                address(polygonZkEVMBridge),
                _l1Escrow,
                ORIGIN_NETWORK_ID,
                _l1Token,
                _l2TokenAddress
            )
        );

        return
            _create3Deploy(
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _symbol)),
                escrowImplementation,
                data
            );
    }

    function _deployL2Convertor(
        bytes memory _symbol,
        address _l2Token
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2TokenConverter.initialize,
            (l2Admin, escrowManager, riskManager, _l2Token)
        );

        return
            _create3Deploy(
                keccak256(
                    abi.encodePacked(bytes("L2TokenConverter:"), _symbol)
                ),
                convertorImplementation,
                data
            );
    }

    function getL1Deployer() public view virtual override returns (address) {
        return l1Deployer;
    }

    function getL2Deployer() public view virtual override returns (address) {
        return address(this);
    }
}

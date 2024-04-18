// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Proxy} from "@zkevm-stb/Proxy.sol";
import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";

import {L2Escrow} from "@zkevm-stb/L2Escrow.sol";
import {L2Token} from "@zkevm-stb/L2Token.sol";
import {L2TokenConverter} from "@zkevm-stb/L2TokenConverter.sol";

import {ICREATE3Factory} from "./interfaces/ICREATE3Factory.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract L2Deployer {
    event NewToken(
        address indexed l1Token,
        address indexed l2Token,
        address indexed l2Escrow,
        address l2Convertor
    );

    struct TokenInfo {
        address l1Token;
        address l2Token;
        address l1Escrow;
        address l2Escrow;
        address l2Convertor;
    }

    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    ICREATE3Factory internal constant create3Factory =
        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);

    address public immutable polygonZkEVMBridge;

    address public immutable counterpartContract;

    address public l2Admin;

    address public riskManager;

    address public escrowManager;

    address public tokenImplementation;

    address public escrowImplementation;

    address public convertorImplementation;

    //
    mapping(string => TokenInfo) public tokenInfo;

    constructor(
        address _l2Admin,
        address _riskManager,
        address _escrowManager,
        address _polygonZkEVMBridge,
        address _counterpartContract,
        address _tokenImplementation,
        address _escrowImplementation,
        address _convertorImplementation
    ) {
        l2Admin = _l2Admin;
        riskManager = _riskManager;
        escrowManager = _escrowManager;
        polygonZkEVMBridge = _polygonZkEVMBridge;
        counterpartContract = _counterpartContract;
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
            polygonZkEVMBridge == msg.sender,
            "L2Deployer: Not PolygonZkEVMBridge"
        );
        require(
            counterpartContract == originAddress,
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
        address _l2Escrow = _deployL2Escrow(_symbol, _l1Token, _l2Token);
        require(_l2Escrow == expectedEscrowAddress, "wrong address");

        // Deploy Convertor
        address _l2Convertor = _deployL2Convertor(_symbol, _l2Token);
        require(_l2Convertor == expectedConvertorAddress, "wrong address");

        // Store Data
        tokenInfo[string(_symbol)] = TokenInfo({
            l1Escrow: _l1Escrow,
            l2Escrow: _l2Escrow,
            l1Token: _l1Token,
            l2Token: _l2Token,
            l2Convertor: _l2Convertor
        });

        emit NewToken(_l1Token, _l2Token, _l2Escrow, _l2Convertor);
    }

    function _deployL2Token(
        string memory _name,
        bytes memory _symbol,
        address _l2Escrow,
        address _l2Convertor
    ) internal virtual returns (address _tokenAddress) {
        bytes memory data = abi.encodeWithSelector(
            L2Token.initialize.selector,
            l2Admin,
            _l2Escrow,
            _l2Convertor,
            _name,
            string(_symbol)
        );

        bytes memory creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(tokenImplementation, data)
        );

        _tokenAddress = create3Factory.deploy(
            keccak256(abi.encodePacked(bytes("L2Token:"), _symbol)),
            creationCode
        );
    }

    function _deployL2Escrow(
        bytes memory _symbol,
        address _originTokenAddress,
        address _l2TokenAddress
    ) internal virtual returns (address _escrowAddress) {
        bytes memory data = abi.encodeWithSelector(
            L2Escrow.initialize.selector,
            l2Admin,
            polygonZkEVMBridge,
            counterpartContract,
            ORIGIN_NETWORK_ID,
            _originTokenAddress,
            _l2TokenAddress
        );

        bytes memory creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(escrowImplementation, data)
        );

        _escrowAddress = create3Factory.deploy(
            keccak256(abi.encodePacked(bytes("L2Escrow:"), _symbol)),
            creationCode
        );
    }

    function _deployL2Convertor(
        bytes memory _symbol,
        address _l2Token
    ) internal virtual returns (address _convertorAddress) {
        bytes memory data = abi.encodeWithSelector(
            L2TokenConverter.initialize.selector,
            l2Admin,
            escrowManager,
            riskManager,
            _l2Token
        );

        bytes memory creationCode = abi.encodePacked(
            type(Proxy).creationCode,
            abi.encode(convertorImplementation, data)
        );

        _convertorAddress = create3Factory.deploy(
            keccak256(abi.encodePacked(bytes("L2TokenConverter:"), _symbol)),
            creationCode
        );
    }

    function getL1EscrowAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL1EscrowAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL1EscrowAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                counterpartContract,
                keccak256(abi.encodePacked(bytes("L1Escrow:"), _symbol))
            );
    }

    function getL2EscrowAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2EscrowAddress(bytes(ERC20(_asset).symbol()));
    }

    // Address will be the L2 deployer
    function _getL2EscrowAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                address(this),
                keccak256(abi.encodePacked(bytes("L2Escrow:"), _symbol))
            );
    }

    function getL2TokenAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2TokenAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL2TokenAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                address(this),
                keccak256(abi.encodePacked(bytes("L2Token:"), _symbol))
            );
    }

    function getL2ConvertorAddress(
        address _asset
    ) external view virtual returns (address) {
        return _getL2ConvertorAddress(bytes(ERC20(_asset).symbol()));
    }

    function _getL2ConvertorAddress(
        bytes memory _symbol
    ) internal view returns (address) {
        return
            create3Factory.getDeployed(
                address(this),
                keccak256(abi.encodePacked(bytes("L2TokenConverter:"), _symbol))
            );
    }
}

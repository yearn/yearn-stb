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

    /// @notice Emitted when a new address is set for a position.
    event UpdatePositionHolder(
        bytes32 indexed position,
        address indexed newAddress
    );

    /// @notice Only allow position holder to call.
    modifier onlyPositionHolder(bytes32 _positionId) {
        _isPositionHolder(_positionId);
        _;
    }

    /// @notice Check if the msg sender is specified position holder.
    function _isPositionHolder(bytes32 _positionId) internal view virtual {
        require(msg.sender == getPositionHolder(_positionId), "!allowed");
    }

    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    /// @notice Position ID's for all used positions
    bytes32 public constant L2_ADMIN = keccak256("L2 Admin");
    bytes32 public constant RISK_MANAGER = keccak256("Risk Manager");
    bytes32 public constant PENDING_ADMIN = keccak256("Pending Admin");
    bytes32 public constant ESCROW_MANAGER = keccak256("Escrow Manager");
    bytes32 public constant TOKEN_IMPLEMENTATION =
        keccak256("Token Implementation");
    bytes32 public constant CONVERTOR_IMPLEMENTATION =
        keccak256("Convertor Implementation");

    /// @notice Mapping of position ID to holder.
    mapping(bytes32 => address) internal _positions;

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
        _setPositionHolder(L2_ADMIN, _l2Admin);
        _setPositionHolder(L1_DEPLOYER, _l1Deployer);
        _setPositionHolder(RISK_MANAGER, _riskManager);
        _setPositionHolder(ESCROW_MANAGER, _escrowManager);
        _setPositionHolder(TOKEN_IMPLEMENTATION, _tokenImplementation);
        _setPositionHolder(ESCROW_IMPLEMENTATION, _escrowImplementation);
        _setPositionHolder(CONVERTOR_IMPLEMENTATION, _convertorImplementation);
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
        (
            address _l1Token,
            address _l1Escrow,
            string memory _name,
            string memory _symbol
        ) = abi.decode(data, (address, address, string, string));

        // Get addresses
        address expectedTokenAddress = getL2TokenAddress(_l1Token);
        address expectedEscrowAddress = getL2EscrowAddress(_l1Token);
        address expectedConvertorAddress = getL2ConvertorAddress(_l1Token);

        // Deploy Token
        address _l2Token = _deployL2Token(
            _name,
            _symbol,
            _l1Token,
            expectedEscrowAddress,
            expectedConvertorAddress
        );
        require(_l2Token == expectedTokenAddress, "wrong address");

        // Deploy escrow
        address _l2Escrow = _deployL2Escrow(_l1Token, _l2Token, _l1Escrow);
        require(_l2Escrow == expectedEscrowAddress, "wrong address");

        // Deploy Convertor
        address _l2Convertor = _deployL2Convertor(_l1Token, _l2Token);
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
        string memory _symbol,
        address _l1Token,
        address _l2Escrow,
        address _l2Convertor
    ) internal virtual returns (address) {
        bytes memory data = abi.encodeCall(
            L2Token.initialize,
            (
                getPositionHolder(L2_ADMIN),
                _l2Escrow,
                _l2Convertor,
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

    function _deployL2Convertor(
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
                getPositionHolder(CONVERTOR_IMPLEMENTATION),
                data
            );
    }

    /**
     * @notice Setter function for updating a positions holder.
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
     * @notice Setter function for updating a positions holder.
     */
    function _setPositionHolder(
        bytes32 _position,
        address _newHolder
    ) internal virtual {
        _positions[_position] = _newHolder;

        emit UpdatePositionHolder(_position, _newHolder);
    }

    /**
     * @notice Get the current address assigned to a specific position.
     * @param _positionId The position identifier.
     * @return The current address assigned to the specified position.
     */
    function getPositionHolder(
        bytes32 _positionId
    ) public view virtual returns (address) {
        return _positions[_positionId];
    }

    function getL1Deployer() public view virtual override returns (address) {
        return getPositionHolder(L1_DEPLOYER);
    }

    function getL2Deployer() public view virtual override returns (address) {
        return address(this);
    }

    function getEscrowImplementation()
        external
        view
        virtual
        override
        returns (address)
    {
        return getPositionHolder(ESCROW_IMPLEMENTATION);
    }

    function getL2Admin() external view virtual returns (address) {
        return getPositionHolder(L2_ADMIN);
    }

    function getRiskManager() external view virtual returns (address) {
        return getPositionHolder(RISK_MANAGER);
    }

    function getPendingAdmin() external view virtual returns (address) {
        return getPositionHolder(PENDING_ADMIN);
    }

    function getEscrowManager() external view virtual returns (address) {
        return getPositionHolder(ESCROW_MANAGER);
    }

    function getTokenImplementation() external view virtual returns (address) {
        return getPositionHolder(TOKEN_IMPLEMENTATION);
    }

    function getConvertorImplementation()
        external
        view
        virtual
        returns (address)
    {
        return getPositionHolder(CONVERTOR_IMPLEMENTATION);
    }
}

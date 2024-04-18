// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.8.18;

/**
 * @title IAccountantFactory
 */
interface IAccountantFactory {
    event NewAccountant(address indexed newAccountant);

    /**
     * @dev Deploys a new Accountant contract with specified fee configurations and addresses
     * @param feeManager The address to receive management and performance fees
     * @param feeRecipient The address to receive refund fees
     * @param defaultManagement Default management fee
     * @param defaultPerformance Default performance fee
     * @param defaultRefund Default refund ratio
     * @param defaultMaxFee Default maximum fee
     * @param defaultMaxGain Default maximum gain
     * @param defaultMaxLoss Default maximum loss
     * @return _newAccountant The address of the newly deployed Accountant contract
     */
    function newAccountant(
        address feeManager,
        address feeRecipient,
        uint16 defaultManagement,
        uint16 defaultPerformance,
        uint16 defaultRefund,
        uint16 defaultMaxFee,
        uint16 defaultMaxGain,
        uint16 defaultMaxLoss
    ) external returns (address _newAccountant);
}

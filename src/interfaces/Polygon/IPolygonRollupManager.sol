// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

interface IPolygonRollupManager {
    /**
     * @notice Struct which will be stored for every batch sequence
     * @param accInputHash Hash chain that contains all the information to process a batch:
     * Before etrog: keccak256(bytes32 oldAccInputHash, keccak256(bytes transactions), bytes32 globalExitRoot, uint64 timestamp, address seqAddress)
     * Etrog: keccak256(bytes32 oldAccInputHash, keccak256(bytes transactions), bytes32 l1InfoRoot/forcedGlobalExitRoot, uint64 currentTimestamp/forcedTimestamp, address l2Coinbase, bytes32 0/forcedBlockHashL1)
     * @param sequencedTimestamp Sequenced timestamp
     * @param previousLastBatchSequenced Previous last batch sequenced before the current one, this is used to properly calculate the fees
     */
    struct SequencedBatchData {
        bytes32 accInputHash;
        uint64 sequencedTimestamp;
        uint64 previousLastBatchSequenced;
    }

    /**
     * @notice Struct to store the pending states
     * Pending state will be an intermediary state, that after a timeout can be consolidated, which means that will be added
     * to the state root mapping, and the global exit root will be updated
     * This is a protection mechanism against soundness attacks, that will be turned off in the future
     * @param timestamp Timestamp where the pending state is added to the queue
     * @param lastVerifiedBatch Last batch verified batch of this pending state
     * @param exitRoot Pending exit root
     * @param stateRoot Pending state root
     */
    struct PendingState {
        uint64 timestamp;
        uint64 lastVerifiedBatch;
        bytes32 exitRoot;
        bytes32 stateRoot;
    }

    /**
     * @notice Struct which to store the rollup data of each chain
     * @param rollupContract Rollup consensus contract, which manages everything
     * related to sequencing transactions
     * @param chainID Chain ID of the rollup
     * @param verifier Verifier contract
     * @param forkID ForkID of the rollup
     * @param batchNumToStateRoot State root mapping
     * @param sequencedBatches Queue of batches that defines the virtual state
     * @param pendingStateTransitions Pending state mapping
     * @param lastLocalExitRoot Last exit root verified, used for compute the rollupExitRoot
     * @param lastBatchSequenced Last batch sent by the consensus contract
     * @param lastVerifiedBatch Last batch verified
     * @param lastPendingState Last pending state
     * @param lastPendingStateConsolidated Last pending state consolidated
     * @param lastVerifiedBatchBeforeUpgrade Last batch verified before the last upgrade
     * @param rollupTypeID Rollup type ID, can be 0 if it was added as an existing rollup
     * @param rollupCompatibilityID Rollup ID used for compatibility checks when upgrading
     */
    struct RollupData {
        IPolygonRollupContract rollupContract;
        uint64 chainID;
        IVerifierRollup verifier;
        uint64 forkID;
        //mapping(uint64 batchNum => bytes32) batchNumToStateRoot;
        //mapping(uint64 batchNum => SequencedBatchData) sequencedBatches;
        //mapping(uint256 pendingStateNum => PendingState) pendingStateTransitions;
        bytes32 lastLocalExitRoot;
        uint64 lastBatchSequenced;
        uint64 lastVerifiedBatch;
        uint64 lastPendingState;
        uint64 lastPendingStateConsolidated;
        uint64 lastVerifiedBatchBeforeUpgrade;
        uint64 rollupTypeID;
        uint8 rollupCompatibilityID;
    }

    function bridgeAddress() external view returns (address);

    // Chain ID mapping for nullifying
    function chainIDToRollupID(
        uint64 chainID
    ) external view returns (uint32 rollupID);

    // Rollups ID mapping
    function rollupIDToRollupData(
        uint32 rollupID
    ) external view returns (RollupData memory);

    // Rollups address mapping
    function rollupAddressToID(
        address rollupAddress
    ) external view returns (uint32 rollupID);
}

interface IPolygonRollupBase {
    function initialize(
        address _admin,
        address sequencer,
        uint32 networkID,
        address gasTokenAddress,
        string memory sequencerURL,
        string memory _networkName
    ) external;

    function onVerifyBatches(
        uint64 lastVerifiedBatch,
        bytes32 newStateRoot,
        address aggregator
    ) external;
}

interface IPolygonRollupContract is IPolygonRollupBase {
    function admin() external view returns (address);
}

/**
 * @dev Define interface verifier
 */
interface IVerifierRollup {
    function verifyProof(
        bytes32[24] calldata proof,
        uint256[1] calldata pubSignals
    ) external view returns (bool);
}

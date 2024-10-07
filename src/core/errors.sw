library;

pub enum RedStoneError {
    EmptyAllowedSigners: (),
    EmptyFeedIds: (),
    SignerCountThresholdToSmall: (),
    DuplicatedSigner: (),
    DuplicatedFeedId: (),
    // (signer, feed_id)
    DuplicatedValueForSigner: (b256, u256),
    // (signer, index)
    SignerNotRecognized: (b256, u64),
    // (signer_count, feed_index)
    InsufficientSignerCount: (u64, u64),
    // (too_future, block_timestamp, timestamp)
    TimestampOutOfRange: (bool, u64, u64),
    // (reference_timestamp, timestamp)
    TimestampDifferentThanOthers: (u64, u64, u64),
}

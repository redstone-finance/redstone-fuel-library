library;

// 2_621_440_000 + 1/2
pub const TIMESTAMP_OUT_OF_RANGE = 0x9C40_0000;

// 1_966_080_000 + data_package_index
pub const TIMESTAMP_DIFFERENT_THAN_OTHERS = 0x7530_0000;

/// 655_360_000 + feed_index
pub const INSUFFICIENT_SIGNER_COUNT = 0x2710_0000;

/// 1_310_720_000 + data_package_index
pub const SIGNER_NOT_RECOGNIZED = 0x4e20_0000;

/// convert 3_276_800_000 + signer_count * feed_index + signer_index
pub const DUPLICATED_VALUE_FOR_SIGNER = 0xc350_0000;

pub enum RedStoneError {
    EmptyAllowedSigners: (),
    EmptyFeedIds: (),
    SignerCountThresholdToSmall: (),
    DuplicatedSigner: (),
    DuplicatedFeedId: (),
}

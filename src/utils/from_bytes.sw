library;

use std::bytes::Bytes;
// use ::utils::from_bytes_convertible::*;
use std::bytes_conversions::{u256::*, u64::*};
pub trait FromBytes {
    fn from_bytes(bytes: Bytes) -> Self;
}
impl FromBytes for u256 {
    fn from_bytes(bytes: Bytes) -> Self {
        assert(bytes.len() <= 32);
        let mut bytes = bytes;
        while (bytes.len() < 32) {
            bytes.insert(0, 0u8);
        }
        Self::from_be_bytes(bytes)
    }
}
impl FromBytes for u64 {
    fn from_bytes(bytes: Bytes) -> Self {
        assert(bytes.len() <= 8);
        let mut bytes = bytes;
        while (bytes.len() < 8) {
            bytes.insert(0, 0u8);
        }
        Self::from_be_bytes(bytes)
    }
}

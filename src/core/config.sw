library;

use std::option::*;
use ::utils::vec::*;

pub struct Config {
    pub signers: Vec<b256>,
    pub feed_ids: Vec<u256>,
    pub signer_count_threshold: u64,
    pub block_timestamp: u64, // unix
}

impl Config {
    pub fn cap(self) -> u64 {
        self.signers.len() * self.feed_ids.len()
    }

    pub fn signer_index(self, signer: b256) -> Option<u64> {
        self.signers.index_of(signer)
    }

    pub fn feed_id_index(self, feed_id: u256) -> Option<u64> {
        self.feed_ids.index_of(feed_id)
    }

    pub fn index(self, feed_id_index: u64, signer_index: u64) -> u64 {
        self.signers.len() * feed_id_index + signer_index
    }
}

library;

use ::protocol::{data_package::DataPackage, payload::Payload};
use ::core::{config::Config, errors::*, validation::*};
use ::utils::{from_bytes::*, vec::*};

trait Validation {
    fn validate_timestamps(self, payload: Payload);
    fn validate_signer_count(self, values: Vec<Vec<u256>>);
    fn validate_signer(self, data_package: DataPackage, index: u64) -> Option<u64>;
}

impl Validation for Config {
    fn validate_timestamps(self, payload: Payload) {
        let mut i = 0;
        while (i < payload.data_packages.len()) {
            let timestamp = payload.data_packages.get(i).unwrap().timestamp / 1000;
            let block_timestamp = self.block_timestamp;

            validate_timestamp(i, timestamp, block_timestamp);

            i += 1;
        }
    }

    fn validate_signer_count(self, results: Vec<Vec<u256>>) {
        let mut i = 0;
        while (i < self.feed_ids.len()) {
            let values = results.get(i).unwrap();
            if (values.len() < self.signer_count_threshold) {
                log(values.len());
                revert(INSUFFICIENT_SIGNER_COUNT + i);
            }

            i += 1;
        }
    }

    fn validate_signer(self, data_package: DataPackage, index: u64) -> Option<u64> {
        let s = self.signer_index(data_package.signer_address);

        if s.is_none() {
            log(data_package.signer_address);
            log(index);
            // revert(SIGNER_NOT_RECOGNIZED + index);
        }

        s
    }
}

#[test]
fn test_validate_one_signer() {
    let results = make_results();
    let config = make_config(1);

    config.validate_signer_count(results);
}

#[test]
fn test_validate_two_signers() {
    let results = make_results();
    let config = make_config(2);

    config.validate_signer_count(results);
}

#[test(should_revert)]
fn test_validate_three_signers() {
    let results = make_results();
    let config = make_config(3);

    config.validate_signer_count(results);
}

fn make_results() -> Vec<Vec<u256>> {
    let mut results = Vec::<Vec<u256>>::new();

    let set1 = Vec::<u256>::new().with(0x111u256).with(0x777u256);
    let set2 = Vec::<u256>::new().with(0x444u256).with(0x555u256).with(0x666u256);
    let set3 = Vec::<u256>::new().with(0x222u256).with(0x333u256);

    results.with(set1).with(set2).with(set3)
}

fn make_config(signer_count_threshold: u64) -> Config {
    let feed_ids = Vec::<u256>::new().with(0x444444u256).with(0x445566u256).with(0x556644u256);

    let config = Config {
        feed_ids,
        signers: Vec::new(),
        signer_count_threshold,
        block_timestamp: 0,
    };

    config
}

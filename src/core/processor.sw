library;

use std::{bytes::*, logging::log, option::*, primitive_conversions::u256::*, vec::*};
use ::protocol::payload::Payload;
use ::utils::sample::{SAMPLE_SIGNER_ADDRESS_0, SAMPLE_SIGNER_ADDRESS_1, SamplePayload,};
use ::core::{aggregation::*, config::Config, config_validation::*,};

/// The main processor of the RedStone payload.
///
///
/// # Arguments
///
/// * `config` - Configuration of the payload processing.
/// * `payload_bytes` - Network-specific byte-list of the payload to be processed.
pub fn process_input(bytes: Bytes, config: Config) -> (Vec<u256>, u64) {
    let payload = Payload::from_bytes(bytes);
    config.validate_timestamps(payload);

    let matrix = get_payload_result_matrix(payload, config);
    let results = get_feed_values(matrix, config);

    config.validate_signer_count(results);

    let timestamp = payload.data_packages.get(0).unwrap().timestamp;
    (results.aggregated(), timestamp)
}

fn get_feed_values(matrix: Vec<Option<u256>>, config: Config) -> Vec<Vec<u256>> {
    let mut results = Vec::new();

    let mut f = 0;
    while (f < config.feed_ids.len()) {
        let mut s = 0;
        let mut values = Vec::new();
        while (s < config.signers.len()) {
            let index = config.index(f, s);
            match matrix.get(index).unwrap() {
                Some(value) => {
                    values.push(value);
                },
                None => (),
            }
            s += 1;
        }
        results.push(values);
        f += 1;
    }

    results
}

fn get_payload_result_matrix(payload: Payload, config: Config) -> Vec<Option<u256>> {
    let mut i = 0;
    let mut j = 0;
    let mut results = Vec::new();

    while (i < config.cap()) {
        results.push(None);
        i += 1;
    }

    i = 0;
    while (i < payload.data_packages.len()) {
        let data_package = payload.data_packages.get(i).unwrap();
        let s = config.validate_signer(data_package, i);

        if (s.is_none()) {
            i += 1;
            continue;
        }

        j = 0;
        while (j < data_package.data_points.len()) {
            let data_point = data_package.data_points.get(j).unwrap();
            let f = config.feed_id_index(data_point.feed_id);
            if f.is_none() {
                j += 1;
                continue;
            }

            let index = config.index(f.unwrap(), s.unwrap());
            results.set(index, Some(data_point.value));
            j += 1;
        }

        i += 1;
    }

    results
}

const TIMESTAMP = 1678113540;

const AVAX = 0x41564158u256;
const BTC = 0x425443u256;
const ETH = 0x455448u256;

#[test]
fn test_process_input_payload_2btc_2eth() {
    let payload = SamplePayload::eth_btc_2x2();
    let config = make_config(TIMESTAMP + 60, 2, Some(BTC), true);

    let (results, timestamp) = process_input(payload.bytes(), config);

    assert(results.get(0).unwrap() == 156962499984);
    assert(results.get(1).unwrap() == 2242266554738);
    assert(timestamp == 1000 * TIMESTAMP);
}

#[test]
fn test_process_input_payload_2btc_2eth_but_btc_not_needed() {
    let payload = SamplePayload::eth_btc_2x2();
    let config = make_config(TIMESTAMP + 60, 2, None, true);

    let (results, _) = process_input(payload.bytes(), config);

    assert(results.get(0).unwrap() == 156962499984);
    assert(results.get(1).is_none());
}

#[test(should_revert)]
fn test_process_input_should_revert_for_payload_2btc_2eth_but_missing_avax() {
    let payload = SamplePayload::eth_btc_2x2();
    let config = make_config(TIMESTAMP + 60, 2, Some(AVAX), true);

    let _ = process_input(payload.bytes(), config);
}

#[test]
fn test_process_input_payload_1btc_2eth_1signer_required() {
    let payload = SamplePayload::eth_btc_2plus1();
    let config = make_config(TIMESTAMP + 60, 1, Some(BTC), true);

    let (results, _) = process_input(payload.bytes(), config);

    assert(results.get(0).unwrap() == 156962499984);
    assert(results.get(1).unwrap() == 0x20a10566cd6);
}

#[test(should_revert)]
fn test_process_input_should_revert_for_payload_1btc_2eth_2signers_required() {
    let payload = SamplePayload::eth_btc_2plus1();
    let config = make_config(TIMESTAMP + 60, 2, Some(BTC), true);

    let _ = process_input(payload.bytes(), config);
}

#[test]
fn test_process_input_payload_1btc_2eth_1signer_allowed() {
    let payload = SamplePayload::eth_btc_2plus1();
    let config = make_config(TIMESTAMP + 60, 1, Some(BTC), false);

    let (results, _) = process_input(payload.bytes(), config);

    assert(results.get(0).unwrap() == 0x248b314244);
    assert(results.get(1).unwrap() == 0x20a10566cd6);
}

#[test]
fn test_process_input_payload_2btc_2eth_1signer_allowed() {
    let payload = SamplePayload::eth_btc_2x2();
    let config = make_config(TIMESTAMP + 60, 1, Some(BTC), false);

    let (results, _) = process_input(payload.bytes(), config);

    assert(results.get(0).unwrap() == 0x248b314244);
    assert(results.get(1).unwrap() == 0x20a10566cd6);
}

#[test(should_revert)]
fn test_process_input_should_revert_for_payload_with_too_big_timestamp_span() {
    let payload = SamplePayload::big_timestamp_span();
    let config = make_config(1677588880, 1, None, false);

    let _ = process_input(payload.bytes(), config);
}

fn make_config(
    block_timestamp: u64,
    signer_count_threshold: u64,
    additional_feed_id: Option<u256>,
    with_second_signer: bool,
) -> Config {
    let mut feed_ids = Vec::new();
    feed_ids.push(ETH);
    if (!additional_feed_id.is_none()) {
        feed_ids.push(additional_feed_id.unwrap());
    }

    let mut signers = Vec::new();
    signers.push(SAMPLE_SIGNER_ADDRESS_0);

    if (with_second_signer) {
        signers.push(SAMPLE_SIGNER_ADDRESS_1);
    }

    Config {
        feed_ids: feed_ids,
        signers: signers,
        signer_count_threshold,
        block_timestamp,
    }
}

This repository is an integral part of the https://github.com/redstone-finance/redstone-oracles-monorepo repository,
especially of the fuel-connector
package (https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/fuel-connector)
and is subject of all their licenses.

### Usage:

📟
Prerequisites: [Read how the RedStone Oracles work](https://docs.redstone.finance/docs/smart-contract-devs/how-it-works).

Write the following to your `Forc.toml` file:

```toml
[dependencies]
redstone = { git = "https://github.com/redstone-finance/redstone-fuel-sdk", branch = "sway-0.63.1" }
```

To process a RedStone payload (with the structure
defined [here](https://docs.redstone.finance/docs/smart-contract-devs/how-it-works#data-packing-off-chain-data-encoding))
for a defined list of `feed_ids`, write the `.sw` file as follows:

```rust
library;

use std::{block::timestamp, bytes::Bytes};
use redstone::{core::config::Config, core::processor::process_input, utils::vec::*};

fn get_timestamp() -> u64 {
    timestamp() - (10 + (1 << 62))
}

fn process_payload(feed_ids: Vec<u256>, payload_bytes: Bytes) -> (Vec<u256>, u64) {
    let signers: Vec<b256> = Vec::new().with(0x00000000000000000000000012470f7aba85c8b81d63137dd5925d6ee114952b);
    let signer_count_threshold = 1; // for example, a value stored in the contract
    let config = Config {
        feed_ids,
        signers,
        signer_count_threshold,
        block_timestamp: get_timestamp(),
    };

    process_input(payload_bytes, config)
}
```

Each item of `feed_ids` is a string encoded to `u256` which means, that's a value
consisting of hex-values of the particular letters in the string. For example:
`ETH` as a `u256` is `0x455448u256` in hex or `4543560` in decimal,
as `256*256*ord('E')+256*ord('T')+ord('H')`.
<br />
📟 To convert particular values, you can use the https://cairo-utils-web.vercel.app/ endpoint.<br />

The data packages transferred to the contract are being verified by signature checking.
To be counted to achieve the `signer_count_threshold`, the signer signing the passed data
should be one of the `signers` passed in the config.

The function returns a `Vec` of aggregated values of each feed passed as an identifier inside `feed_ids`
and the minimal data timestamp read from the payload_bytes.

### Sample contracts

See
more [here](https://github.com/redstone-finance/redstone-oracles-monorepo/blob/main/packages/fuel-connector/sway/contract/README.md)

### Docs

See [here](https://redstone-docs-git-fuel-docs-redstone-finance.vercel.app/sway/redstone/index.html)

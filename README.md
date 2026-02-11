Work in progress: Not production-ready.

# SHA256 Verifiation in Noir
Idea: Noir circuit generates proof that the Prover knows a 32-byte preimage that hashes to a public value.

This repo contains:
- external computation of a SHA256 Hash of a 32 byte secret in Rust. The hash serves as input for Noir's Prover.toml
- Noir circuit that verifies the hash correctness

### Circuit details

pub inputs:
hashed secret

priv inputs:
unhashed secret

Assertion: re-computed H(secret) = hashed secret

# Limitations

- Secret is hardcoded
- no Field encoding is used

# How to run

```
cargo run # generate Prover.toml
nargo check
nargo execute
bb prove
bb verify
```

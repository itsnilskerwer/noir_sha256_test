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
- no Field encoding is used, as it owuld require unpacking in-circuit. TODO: possibly test for optimization here.

# How to run

nargo check
nargo execute
bb prove -w ./target/sha256_test.gz -b ./target/sha256_test.json -o ./target/proof
[write verification key to file for verification]
bb prove -w ./target/sha256_test.gz -b ./target/sha256_test.json --write_vk -o ./target/proof
bb verify -p ./target/proof/proof -k ./target/proof/vk -i ./target/proof/public_inputs

## Benchmarking

### nargo info

[dependencies]: sha256 "v0.2.1", (https://github.com/noir-lang/sha256)

```text
+-------------+----------------------------+----------------------+--------------+-----------------+
| Package     | Function                   | Expression Width     | ACIR Opcodes | Brillig Opcodes |
+-------------+----------------------------+----------------------+--------------+-----------------+
| sha256_test | main                       | Bounded { width: 4 } | 354          | 543             |
+-------------+----------------------------+----------------------+--------------+-----------------+
| sha256_test | build_msg_block            | N/A                  | N/A          | 242             |
+-------------+----------------------------+----------------------+--------------+-----------------+
| sha256_test | attach_len_to_msg_block    | N/A                  | N/A          | 276             |
+-------------+----------------------------+----------------------+--------------+-----------------+
| sha256_test | directive_integer_quotient | N/A                  | N/A          | 8               |
+-------------+----------------------------+----------------------+--------------+-----------------+
| sha256_test | directive_to_radix         | N/A                  | N/A          | 17              |
+-------------+----------------------------+----------------------+--------------+-----------------+
```

[dependencies]: "v0.3.0", git = "https://github.com/noir-lang/sha256"

```text
+-------------+------------------------+----------------------+--------------+-----------------+
| Package     | Function               | Expression Width     | ACIR Opcodes | Brillig Opcodes |
+-------------+------------------------+----------------------+--------------+-----------------+
| sha256_test | main                   | Bounded { width: 4 } | 181          | 259             |
+-------------+------------------------+----------------------+--------------+-----------------+
| sha256_test | build_msg_block_helper | N/A                  | N/A          | 242             |
+-------------+------------------------+----------------------+--------------+-----------------+
| sha256_test | directive_to_radix     | N/A                  | N/A          | 17              |
+-------------+------------------------+----------------------+--------------+-----------------+
```

## Profile (v.0.3.0)

### opcodes

Running `noir-profiler opcodes --artifact-path ./target/sha256_test.json --output ./target/`

`
Opcode count for main: 181
Opcode count for build_msg_block_helper_0_brillig: 242
Opcode count for directive_to_radix_1_brillig: 17
`

### gates

Running `noir-profiler gates --artifact-path ./target/sha256_test.json --backend-path bb --output ./target -- --include_gates_per_opcode`

`Opcode count: 181, Total gates by opcodes: 6867, Circuit size: 6884`


Note: After running profile commands, SVG files are stored in target/. They are viewable in browser and show profiler outputs interactively.
Explained in Noir docs, fitting the profile of this circuit:
> blackbox::range contributes the majority of the backend gates. This comes from how Barretenberg UltraHonk uses lookup tables for its range gates under the hood, which comes with a considerable but fixed setup cost in terms of proving gates.

### profiling execution trace (TODO)

Note: From Noir docs:
>The profiler supports profiling fully unconstrained Noir programs at this moment.
>Similar to the opcodes command, except it additionally takes in the Prover.toml file to profile execution with a specific set of inputs.
>Note that unconstrained Noir functions compile down to Brillig opcodes [...] rather than constrained ACIR opcodes.

Running `noir-profiler execution-opcodes --artifact-path ./target/sha256_test.json --prover-toml-path Prover.toml --output ./target`

## Runtime Benchmarks

Environment:
- CPU: Macbook Pro 1,4 GHz Quad-Core Intel Core i5
- nargo version = 1.0.0-beta.13
- noirc version = 1.0.0-beta.13
- Barretenberg version: v0.87.0
- Runs per phase: 1 (Note: Set to 1 by default)

Running `chmod +x benchmark.sh` on zsh
Then, `./benchmark.sh` .

Results v0.2.1:

`Phase,Average_Time_Seconds
compile,  .307792
execute,  .280920
prove,  .611229`

Results v0.3.0:

`Phase,Average_Time_Seconds
compile,  .281087
execute,  .257887
prove,  .604413

Note: Results vary approx. +- 0.08s
TODO: Test with increased runs

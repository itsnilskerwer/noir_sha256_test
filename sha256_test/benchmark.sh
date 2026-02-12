#!/usr/bin/env bash
set -euo pipefail

# Warning: Not production-ready.
# TODO: compare with public benchmarks

# --------------------------------------------
# Configuration
# --------------------------------------------

RUNS=1
RESULTS_DIR="results"
TARGET_DIR="target"
PROOF_DIR="$TARGET_DIR/proof"
CIRCUIT_NAME="sha256_test"

mkdir -p "$RESULTS_DIR"
mkdir -p "$PROOF_DIR"

OUTPUT_CSV="$RESULTS_DIR/benchmark.csv"

echo "Phase,Average_Time_Seconds" > "$OUTPUT_CSV"

echo "Running benchmark for $CIRCUIT_NAME"
echo "Runs per phase: $RUNS"
echo "--------------------------------------------"

# --------------------------------------------
# Compile Benchmark
# --------------------------------------------

echo "Benchmarking: compile"

compile_total=0

for i in $(seq 1 $RUNS); do
    rm -rf "$TARGET_DIR"

    start=$(date +%s.%N)
    nargo compile >/dev/null 2>&1
    end=$(date +%s.%N)

    elapsed=$(echo "$end - $start" | bc)
    compile_total=$(echo "$compile_total + $elapsed" | bc)
done

compile_avg=$(echo "scale=6; $compile_total / $RUNS" | bc)
echo "compile,$compile_avg" >> "$OUTPUT_CSV"

# --------------------------------------------
# Execute Benchmark (Witness Generation)
# --------------------------------------------

echo "Benchmarking: execute"

execute_total=0

for i in $(seq 1 $RUNS); do
    start=$(date +%s.%N)
    nargo execute >/dev/null 2>&1
    end=$(date +%s.%N)

    elapsed=$(echo "$end - $start" | bc)
    execute_total=$(echo "$execute_total + $elapsed" | bc)
done

execute_avg=$(echo "scale=6; $execute_total / $RUNS" | bc)
echo "execute,$execute_avg" >> "$OUTPUT_CSV"

# --------------------------------------------
# Proving Benchmark (bb prove)
# --------------------------------------------

echo "Benchmarking: prove"

prove_total=0

for i in $(seq 1 $RUNS); do
    start=$(date +%s.%N)

    bb prove \
        -w "$TARGET_DIR/$CIRCUIT_NAME.gz" \
        -b "$TARGET_DIR/$CIRCUIT_NAME.json" \
        -o "$PROOF_DIR/proof_$i" \
        >/dev/null 2>&1

    end=$(date +%s.%N)

    elapsed=$(echo "$end - $start" | bc)
    prove_total=$(echo "$prove_total + $elapsed" | bc)
done

prove_avg=$(echo "scale=6; $prove_total / $RUNS" | bc)
echo "prove,$prove_avg" >> "$OUTPUT_CSV"

echo "--------------------------------------------"
echo "Benchmark complete."
echo "Results saved to $OUTPUT_CSV"

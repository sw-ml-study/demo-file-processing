set shell := ["sh", "-cu"]

# Show available repository tasks.
default:
    @just --list

# Run structural, policy, catalog, fixture, and documentation audits.
audit:
    ./scripts/audit

# Run all native mlplunit tests; extra arguments select paths or filters.
tests *args:
    ./scripts/run-tests {{args}}

# Emit native test results as TAP.
tap *args:
    ./scripts/run-tests --format tap {{args}}

# List tests discovered by mlplunit without executing them.
list-tests:
    ./scripts/run-tests --list

# Print selected tools without installing or replacing them.
mlpl-path:
    ./scripts/select-mlpl

mlplunit-path:
    ./scripts/select-mlplunit

mlpl-build-path:
    ./scripts/select-mlpl-build

# Verify script process behavior and native numeric compiler parity.
capabilities:
    ./scripts/check-process-io
    ./scripts/check-compiler

# Regenerate and validate tiny deterministic byte fixtures.
generate-byte-fixtures:
    ./scripts/generate-byte-fixtures --write

generate-wav-fixtures:
    ./scripts/generate-wav-fixtures --write

# Run the readable byte-processing applications.
hexdump:
    ./scripts/run-byte-demo hexdump

histogram:
    ./scripts/run-byte-demo histogram

# Count bytes through bounded file ranges without whole-file materialization.
bounded-histogram:
    ./scripts/run-byte-demo range_histogram

byte-demos:
    ./scripts/check-byte-demos

# Decode a golden MPEG audio header through a data-described field layout.
binary-fields:
    ./scripts/run-binary-demo mpeg_header

# Inspect and canonically copy a tiny PCM WAV file.
wav-inspect-copy:
    ./scripts/run-wav-demo

# Inspect WAV metadata through bounded reads without retaining sample payloads.
wav-range-inspect:
    ./scripts/run-wav-demo range_inspect

# Opt-in: generate sparse inputs and enforce bounded-read peak-RSS ceilings.
sparse-memory-evidence:
    ./scripts/run-sparse-memory-evidence

# Run the complete pre-commit gate.
check:
    ./scripts/check

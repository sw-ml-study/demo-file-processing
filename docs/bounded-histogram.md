# Bounded byte histogram

The bounded histogram traverses a file through the shared
[`range_reader`](bounded-range-reader.md) contract and merges one 256-bin
histogram per range. It never calls the whole-file `read_bytes(path)` form and
does not retain prior chunks. The runnable demonstration uses a seven-byte
budget, so the 256-byte all-values fixture is reduced in 37 reads.

```sh
just bounded-histogram
just tests tests/bytes/test_range_histogram.mlpl
```

## Ownership and invariants

MLPL owns traversal state, per-chunk histogram calculation, vector addition,
and final totals. The generic native runtime owns metadata lookup and each
bounded range read. No external histogram implementation or oracle is used by
the demo. Tests may use the existing whole-buffer MLPL histogram as an oracle.

The mlplunit suite proves identical 256-bin results for chunk sizes 1, 7, 64,
and 65,536. It covers empty, repeated-byte, `0..16`, and all-byte fixtures,
including final partial ranges, and preserves budget, missing-path, and sandbox
errors. Empty input performs no range read and returns 256 zero bins.

## Complexity and allocation

For `n` input bytes and chunk budget `c`, traversal performs `ceil(n/c)` reads
and carries a constant-sized reader record plus 256 accumulated f64 counts.
The intentionally array-oriented reference histogram constructs a
`256 × chunk_length` equality matrix for each range, so logical time is
O(256n) and peak live numeric payload is O(256c + 256), plus the f64-backed
chunk and runtime/container overhead. Adding each partial histogram also
allocates a new 256-cell accumulator under current immutable array semantics.

This is bounded by chunk size in the program structure and avoids whole-file
materialization. The [sparse-file acceptance harness](sparse-memory-evidence.md)
now backs that structure with fixed-budget peak-RSS evidence across a 16-fold
input-size increase.

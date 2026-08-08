# Bounded range analysis

## 1. Range reader conformance

Implement the smallest reusable MLPL range-reader state/helper over
`file_size` and `read_bytes(path, offset, length)`. Test chunk sizes 1, 7, 64,
and 65,536; empty files; zero-length reads; EOF clamping; beyond-EOF offsets;
invalid offsets/lengths and overflow; missing/denied paths; and sandbox escape
behavior. Use mlplunit for every executable MLPL test and keep ownership and
f64 offset limits explicit.

## 2. Chunk-invariant histogram

Implement bounded range traversal and a 256-bin reduction without whole-file
materialization. Compare every configured chunk size with the existing
whole-buffer oracle, including empty and all-byte fixtures. Document carried
state, complexity, allocation, and any unavoidable MLPL array copies.

## 3. Range-based WAV inspection

Inspect RIFF/WAVE structure and PCM metadata through bounded reads. Split RIFF
and chunk headers at every relevant boundary, cover padding and malformed
lengths, and prove results match the existing canonical whole-buffer parser.
Do not add copy/write claims.

## 4. Sparse-file memory evidence

Generate or describe a deterministic sparse input larger than the configured
memory budget, run bounded histogram and WAV inspection where applicable, and
measure peak resident memory with a documented portable-enough method. Prove
the high-water mark depends on chunk plus state rather than total file size, or
record the exact failed criterion and smallest unblock.

## 5. Bounded-read acceptance report

Run `just check`, reconcile README/catalog/capability/upstream documentation,
and publish executable results and limitations. Stabilize only APIs earned by
the demos. Identify `incremental-binary-output` as gated unless its generic
sink contract has separately been delivered and authorized.

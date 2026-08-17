# Standalone file-application assessment

## Verdict

**Accepted for one narrow whole-input application.** The selected development
compiler produces a genuine native wc-style stdin filter with useful counts,
host-oracle parity, and source-free execution. Bounded stdin, file-path wc,
grep, du, hexdump, histogram, WAV, and Ogg applications remain unaccepted.

This is an evidence-complete assessment of the current boundary, not a
successful standalone delivery. Interpreter applications and their bounded-I/O
claims remain accepted independently.

## Acceptance matrix

| Requirement | Evidence | Result |
|---|---|---|
| Native executable exists | The wc stdin filter compiles and runs through pipes and redirection | Pass for the whole-input wc filter |
| No source/parser/REPL runtime dependency | Controls run from a fresh source-free directory under `env -i`; dependency inspection finds no named parser/REPL/evaluator library | Pass for narrow controls only |
| CLI arguments | `args` and `arg` lower | Pass for the narrow exact-output probes |
| Pristine binary stdout | `write_stdout([0,255])` lowers | Pass: generated `main` emits exactly bytes `00 ff` with no result trailer |
| Byte validation | Interpreter rejects invalid bytes | Pass for probe: compiler exits nonzero, emits the diagnostic on stderr, and writes no binary bytes |
| Output errors | Interpreter returns errors | Fail: compiled runtime discards write/flush failures |
| stdin/stderr/exit | Exact interpreter probe passes | Partial: all lower and effect results no longer add trailers; broader application parity remains unaccepted |
| Source loading | Actual applications compile with the repository passed as `--source-dir` | Pass: include graphs expand and reach lowering |
| User application code | Real expanded and dependency-concatenated demos lower functions, control flow, Results, records, comparisons, tally, indexing, and equality | Partial: remaining demos diverge at entry shape, `pow/2`, `fill/2`, `concat/2`, or `to_string/1` |
| Byte and format I/O | Read/append and bit probes compile and match expected values/bytes | Partial: full application parity still waits on later operations and process semantics |
| wc stdin artifact | Mixed, empty, and terminated inputs plus host `wc` oracle | Pass; whole-input memory only |
| Hexdump/histogram artifact | Actual demos and flattened equivalents are attempted | Fail before artifact production |
| WAV/Ogg artifact | Bounded copy/rewrite demos and flattened equivalents are attempted | Fail before artifact production |
| Clean application audit | wc artifact runs under `env -i`; dependency inspection rejects named parser/REPL/evaluator libraries | Pass for wc stdin artifact |

## Verification completed

The default `just check` gate now includes:

- 120 native mlplunit tests across 35 suites, including the later unified media
  inspector, structural media doctor, and WAV transformation app coverage;
- exact interpreter process and binary-stdout contracts;
- numeric/arithmetic compiler parity;
- exact partial `args`/`arg`/`write_stdout` compiler behavior;
- positive source/function/control-flow/Result/record/I/O/comparison lowering
  plus exact current rejections for actual hexdump, histogram, WAV, Ogg,
  narrated wc, grep, and du applications and dependency-concatenated controls;
- isolated execution and dependency inspection of supported control artifacts;
- exact raw, WAV, Ogg, MP3, bounded-output, CRC, and demo narration oracles.

The remaining expected-failure application probes are deliberate change
detectors. Earlier compiler rungs are now positive prerequisites. When upstream
adds the next missing operations,
the default gate fails rather than silently
preserving a stale blocker report; downstream must then advance the assertion
to the next measured boundary or positive artifact parity.

## Ordered compiler/runtime unblock

The smallest useful upstream sequence is:

1. lower the remaining `pow/2`, `fill/2`, `concat/2`, `to_string/1`, and record-state operations used by the demos;
2. preserve byte validation and provide accepted sink-error propagation;
3. provide clean entry-point behavior, stderr, exit status, and required stdin
   behavior without a generated stdout trailer;
4. compile hexdump and histogram and run the existing fixture matrix in both
   modes;
5. compile bounded WAV or Ogg output, compare exact bytes, semantically reparse
   them, and measure compiled peak RSS; then
6. repeat the clean-environment artifact audit on that useful application.

These are generic compiler/runtime needs. No WAV-, Ogg-, MP3-, or histogram-
specific builtin is requested.

## Separate later blockers

The following remain real but do not explain the current compilation failure:

- **Binary source lifecycle:** binary stdin, consumable source handles,
  persistent seekable handles, explicit backpressure, and cross-call
  transactions are still absent. Seekable interpreter file pipelines remain
  available through bounded range reads.
- **Codec extensions:** MP3 decoding and Vorbis encoding need separately
  authorized chunk-oriented Rust extension contracts, state, flush,
  backpressure, metadata, sample-format, and malformed-stream behavior.
- **Compiler extension parity:** the MP3-to-Ogg capstone additionally needs
  compiled extension registration/linking after generic application parity.
- **Packed bytes and wide integers:** packed u8 storage is a density/performance
  roadmap item, not the blocker for bounded chunked copy. Exact arbitrary
  64-bit fields remain split-word values until a concrete consumer earns a
  native scalar representation.

Codec work can prototype against seekable interpreter file paths, but it cannot
produce the planned standalone capstone until the generic compiler gates above
are cleared.

## Next action

Keep compiler-ready application sources and exact boundary probes current while
upstream compiler/runtime parity changes. Re-run `just check` against each new
adjacent development build;
the first expected-failure oracle that breaks identifies the next positive
downstream parity step. Do not start a new file-application implementation by
wrapping the interpreter or duplicating MLPL algorithms externally.

For upstream coordination, send
[`sw-mlpl-standalone-compiler-handoff.md`](sw-mlpl-standalone-compiler-handoff.md),
which presents the exact evidence, requested order, non-blocking later items,
reproduction commands, and first actionable downstream resume trigger without
requiring the recipient to reconstruct this repository's saga history.

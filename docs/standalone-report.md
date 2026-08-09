# Standalone file-application assessment

## Verdict

**Not accepted.** The selected development compiler produces genuine native
artifacts for a narrow numeric subset and partial argument/stdout operations,
but it does not produce a useful hexdump, histogram, WAV, or Ogg application.
No repository demo is claimed as a standalone native file-processing CLI.

This is an evidence-complete assessment of the current boundary, not a
successful standalone delivery. Interpreter applications and their bounded-I/O
claims remain accepted independently.

## Acceptance matrix

| Requirement | Evidence | Result |
|---|---|---|
| Native executable exists | Numeric reduction and partial stdout controls compile and run | Pass for narrow controls only |
| No source/parser/REPL runtime dependency | Controls run from a fresh source-free directory under `env -i`; dependency inspection finds no named parser/REPL/evaluator library | Pass for narrow controls only |
| CLI arguments | `args` and `arg` lower | Partial: wrapper output and error parity remain unsuitable |
| Pristine binary stdout | `write_stdout([0,255])` lowers | Fail: generated `main` appends `2\n` |
| Byte validation | Interpreter rejects invalid bytes | Fail: compiler coerces `256`, `-1`, `1.5` to `255`, `0`, `1` |
| Output errors | Interpreter returns errors | Fail: compiled runtime discards write/flush failures |
| stdin/stderr/exit | Exact interpreter probe passes | Fail: `read_stdin`, `eprint`, and `exit` are not lowered |
| Source loading | Actual applications use repository-relative includes | Fail: `mlpl-build` rejects `include` |
| User application code | Dependency-concatenated demos reach lowering | Fail: `FnDef` is unsupported; control flow, Results, records, and fields also remain gaps |
| Byte and format I/O | Interpreter bounded reads/appends pass | Fail: `read_bytes`, `file_size`, `append_bytes`, and required bit operations lack compiler parity |
| Hexdump/histogram artifact | Actual demos and flattened equivalents are attempted | Fail before artifact production |
| WAV/Ogg artifact | Bounded copy/rewrite demos and flattened equivalents are attempted | Fail before artifact production |
| Clean application audit | Audit contract and control are executable | Blocked: no useful application artifact exists |

## Verification completed

The default `just check` gate now includes:

- 100 native mlplunit tests across 30 suites, including the later unified media
  inspector and structural media-doctor application coverage;
- exact interpreter process and binary-stdout contracts;
- numeric/arithmetic compiler parity;
- exact partial `args`/`arg`/`write_stdout` compiler behavior;
- expected-failure compilation of actual and dependency-concatenated hexdump,
  histogram, WAV, and Ogg applications;
- isolated execution and dependency inspection of supported control artifacts;
- exact raw, WAV, Ogg, MP3, bounded-output, CRC, and demo narration oracles.

The expected-failure application probes are deliberate change detectors. When
upstream adds source loading or user functions, the default gate fails rather
than silently preserving a stale blocker report; downstream must then replace
the affected negative assertion with positive artifact parity.

## Ordered compiler/runtime unblock

The smallest useful upstream sequence is:

1. resolve source-relative `include` graphs before lowering;
2. lower user functions/calls, conditionals/loops, Results, records, and field
   access with interpreter-equivalent semantics;
3. share byte validation and error propagation instead of coercing values or
   discarding sink failures;
4. lower bounded `read_bytes`, `file_size`, `append_bytes`/binary stdout, and
   the array/bit/text operations used by the existing demos;
5. provide clean entry-point behavior, stderr, exit status, and required stdin
   behavior without a generated stdout trailer;
6. compile hexdump and histogram and run the existing fixture matrix in both
   modes;
7. compile bounded WAV or Ogg output, compare exact bytes, semantically reparse
   them, and measure compiled peak RSS; then
8. repeat the clean-environment artifact audit on that useful application.

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

Pause standalone downstream implementation until upstream compiler/runtime
parity changes. Re-run `just check` against each new adjacent development build;
the first expected-failure oracle that breaks identifies the next positive
downstream parity step. Do not start a new file-application implementation by
wrapping the interpreter or duplicating MLPL algorithms externally.

For upstream coordination, send
[`sw-mlpl-standalone-compiler-handoff.md`](sw-mlpl-standalone-compiler-handoff.md),
which presents the exact evidence, requested order, non-blocking later items,
reproduction commands, and first actionable downstream resume trigger without
requiring the recipient to reconstruct this repository's saga history.

# Measured capability baseline

## Probe environment

Measured on 2026-08-08 on arm64 macOS 26.5 with:

- `mlpl-repl 0.20.0`, embedded build commit `23afb11a`, selected from the
  adjacent release build;
- adjacent sw-MLPL checkout `6156e869b1d20bee5e045f43cd7f9a144233edf2`;
- `mlplunit 0.1.0` at `a06191f800f40a23ebc1890eada3f505b1adab60`;
- adjacent debug `mlpl-build` (the tool exposes no version flag).

`just capabilities` and the native suites beneath `tests/capabilities/` are the
executable record. The configured binary, not the checkout documentation, is
the authority for downstream claims.

## Results

| Surface | Observed result | Consequence |
|---|---|---|
| Whole-file byte I/O | `write_bytes` and one-argument `read_bytes` round-trip `0..=255` through `Result` | Small in-memory demos are unblocked. |
| Byte representation | `read_bytes` returns ordinary `array`; upstream implementation converts `Vec<u8>` to `Vec<f64>` | Values are logical bytes, not packed byte storage; memory/copy costs must say so. |
| Bounded reads | `read_bytes(path, offset, length)` returns only the requested range, clamps at EOF, and `file_size` uses metadata | Bounded random/range analysis is available now; the research transcript's “absent” assumption is stale. |
| Range-reader contract | MLPL validates exact offsets/budgets, prevents range-addition overflow, advances immutable state, detects short reads, and preserves runtime path errors | Chunked read-side consumers can share one tested contract; bounded memory remains a property to prove per consumer. |
| Bounded histogram | MLPL merges per-range 256-bin reductions with identical results at chunk sizes 1, 7, 64, and 65,536 | The code retains no prior chunks, but peak RSS remains unclaimed until sparse-file measurement. |
| Incremental stream handles | No open/read-next/write-next/seek handle surface was found or exercised | Stateful single-pass transforms and codecs remain gated; repeated range reads are not a stream API. |
| Writes | `write_bytes` validates integral byte values and failed validation preserves prior contents | Deterministic whole-buffer writes are usable; bounded/incremental writes remain absent. |
| Bit operations | `band`, `bor`, `bxor`, `bnot`, `popcount`, `shl`, `shr`, `bits`, and `from_bits` pass golden vectors | In-memory endian and field work is unblocked in the interpreter. |
| Endian/layout library | MLPL codecs round-trip exact u8..u48 in both byte orders; width vectors extract MSB-first fields across byte boundaries | WAV-sized integers and MPEG headers need no format/runtime builtin; scalar u56/u64 remains intentionally rejected. |
| MPEG frame scanner | MLPL acquires synchronization with two compatible semantic headers, skips payloads by decoded frame length, reacquires after damage, and reports fixed bitrate/channel histograms plus frame-size statistics | Read-only MP3 ranges can be inspected under explicit byte and frame budgets; free bitrate and measured memory evidence remain out of scope. |
| ID3v2 inspector | MLPL parses bounded v2.3/v2.4 headers and frames, extended headers, padding and v2.4 footers; selected UTF-8/ASCII-compatible text is capped and unknown payloads are skipped by offset | Validated tag/audio descriptors are available without output writes; UTF-16, non-ASCII Latin-1, unsynchronization, compression and encryption remain explicit unsupported cases. |
| Ogg page model | MLPL validates version-zero page headers, flags, lacing/body extents and budgets while retaining only lacing plus descriptors; granule positions remain exact split 32-bit words | Bounded page traversal is unblocked without native Ogg parsing; packet continuation and CRC verification remain separate steps. |
| PCM WAV library | MLPL parses RIFF chunks, validates PCM mono/stereo 8/16-bit metadata/data, and canonically re-encodes tiny fixtures | Small-file WAV inspection/copy is unblocked; unknown chunks normalize away and whole-file f64 copies are not streaming. |
| Bounded WAV inspection | MLPL reads at most 16 header bytes per window, skips payloads by validated offsets, and matches whole-buffer metadata for every header split | Read-only WAV metadata scales structurally without sample retention; copy/write and measured-RSS claims remain separate. |
| Sparse-file peak RSS | Fixed-budget histogram and WAV consumers stayed below a 32 MiB ceiling as artifacts grew to 1 MiB and 64 MiB; repeat growth stayed at or below 1,081,344 bytes | The measured read-side high-water mark depends on chunk plus state, not total file size, on the recorded platform. |
| Exact integer domain | Numeric arrays are f64-backed; `2^53` and mathematical `2^53+1` compare equal; bit operations reject operands at the upper domain boundary upstream | Byte and ordinary 32-bit field work is exact; 64-bit file fields require a split-word representation or a new type. |
| Script process surface | `args`, `read_stdin`, `print`, `eprint`, and `exit(7)` produced separated streams and the requested status | Interpreter-backed Unix-style tools are available now. `read_stdin` is whole-input text, not binary chunk streaming. |
| Native numeric build | `reduce_add(iota(8))` produced `28` in both interpreter and compiled artifact | The native path is real for its supported numeric subset. The artifact runs directly; `otool -L` shows no named MLPL interpreter/parser/evaluator dynamic dependency. |
| Arithmetic build | `(iota(8) + 1) * 2` compiles and its reduction prints `72`, matching the interpreter | The prior generated-trait import defect is resolved in the selected adjacent development build; the gate now requires positive parity. |
| Application lowering | `read_bytes/1`, `args/0`, and `band/2` each fail at lowering as unsupported function calls | A compiled file-processing CLI is gated on generic runtime/lowering parity; interpreter success does not imply compiler success. |

## Claim boundaries

The repository can now truthfully claim:

- whole-file byte arrays and bounded offset/length reads;
- interpreter-side bit manipulation over exact non-negative f64 integers;
- script arguments, text stdin, separated output streams, and exit codes;
- a native compiler path for the tested numeric and arithmetic expressions;
- bounded seekable-file MPEG Layer III structural statistics and ID3v2.3/v2.4
  metadata/audio descriptors without codec or output claims.

It cannot yet claim:

- packed `u8` storage or one byte of resident data per file byte;
- incremental binary input/output, stream handles, backpressure, or codec state;
- exact scalar representation of arbitrary 64-bit file fields;
- interpreter/compiler parity for byte I/O, process APIs, or bit operations;
- compilation of a useful file-processing application;
- compiler lowering of byte I/O, process APIs, or bit operations needed by a
  useful standalone file-processing application.

## Reproduction

```sh
just tests tests/capabilities
just tests tests/io
just capabilities
just check
```

The compiler probe creates its cargo project and native artifact in a temporary
directory and removes them. Cargo may need registry/cache access even though
all MLPL crates are adjacent path dependencies.

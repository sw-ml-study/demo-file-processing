# Measured capability baseline

## Probe environment

Measured on 2026-08-09 on arm64 macOS 26.5 with:

- `mlpl-repl 0.20.0`, embedded build commit `91d5216a`, selected from the
  adjacent release build;
- `mlplunit 0.1.0` at `a06191f800f40a23ebc1890eada3f505b1adab60`;
- adjacent development `mlpl-build`, rebuilt from its current source (the tool
  exposes no version flag and that checkout moves independently).

`just capabilities` and the native suites beneath `tests/capabilities/` are the
executable record. The configured binary, not the checkout documentation, is
the authority for downstream claims.

## Results

| Surface | Observed result | Consequence |
|---|---|---|
| Whole-file byte I/O | `write_bytes` and one-argument `read_bytes` round-trip `0..=255` through `Result` | Small in-memory demos are unblocked. |
| Byte representation | `read_bytes` returns ordinary `array`; upstream implementation converts `Vec<u8>` to `Vec<f64>` | Values are logical bytes, not packed byte storage; memory/copy costs must say so. |
| Bounded reads | `read_bytes(path, offset, length)` returns only the requested range, clamps at EOF, and `file_size` uses metadata | Bounded random/range analysis is available now; the research transcript's “absent” assumption is stale. |
| File-date indexing and ls metadata | Pure MLPL validates exact Unix milliseconds, returns a deterministic available/newest/UTF-8-path permutation, places unavailable rows last, converts epochs to UTC, and renders ISO-8601 milliseconds; live `fs_walk`/`file_metadata` rows match macOS/Linux host kind, size, and timestamp seconds | Live and synthetic paths are accepted. Missing paths and symlink escapes fail; unavailable timestamps remain explicit; `fs_walk` materializes entries and compiled ls stops at later generic lowering. |
| Bounded wc-like counting | MLPL counts physical bytes, LF terminators, explicit logical lines, and ASCII-delimited words identically at chunk sizes 1, 2, 7, and 65,536 | `O(n)` traversal retains only `O(chunk_size)` payload plus scalar state; UTF-8 is byte-counted, CRLF counts one LF line, and a final unterminated line is separate from wc-style `lines`. |
| Standalone wc stdin filter | A compiled native artifact folds `read_stdin_chunk(1)` through scalar state; mixed, empty, terminated, cross-read UTF-8/word, budget-exit, sink-error, host-oracle, and source-free checks pass | Accepted as a bounded pipeline. Complete 1 MiB/64 MiB runs each measured 2,080,768-byte peak RSS (zero growth), supporting `O(chunk_size)` payload memory rather than input retention. |
| Bounded grep-like matching | MLPL finds non-empty literal byte patterns, reports deterministic logical line numbers, and produces identical results across chunk sizes 1, 7, and 64 | Lines are retained only up to `max_line_bytes`; file and match budgets fail explicitly; matching is byte-oriented, LF-delimited, and worst-case `O(n × pattern_bytes)`. |
| Confined du-like logical sizes | MLPL validates lexical regular-file rows, relative depth, exact sizes, entry and sum budgets; the live demo totals six fixtures to 573 bytes and an independent `wc -c` oracle agrees | This is apparent length, not allocated blocks. `fs_walk` confines paths and avoids symlinks but materializes all matches before application budgets, so bounded discovery is not claimed. |
| Range-reader contract | MLPL validates exact offsets/budgets, prevents range-addition overflow, advances immutable state, detects short reads, and preserves runtime path errors | Chunked read-side consumers can share one tested contract; bounded memory remains a property to prove per consumer. |
| Bounded histogram | MLPL merges per-range 256-bin reductions with identical results at chunk sizes 1, 7, 64, and 65,536 | The code retains no prior chunks, but peak RSS remains unclaimed until sparse-file measurement. |
| Incremental stream handles | No open/read-next/write-next/seek handle surface was found or exercised | Stateful single-pass transforms and codecs remain gated; repeated range reads are not a stream API. |
| Writes | `write_bytes` validates integral byte values and failed validation preserves prior contents | Deterministic whole-buffer replacement remains useful for tiny outputs and destination initialization. |
| Incremental file output | `append_bytes(path, bytes)` creates/appends a validated bounded chunk and returns its count; each call implicitly closes/flushes | File-path output can be bounded by chunk size; callers must initialize destinations and define partial-output cleanup. Compiler lowering remains absent. |
| Binary stdout sink | `write_stdout(bytes)` accepts scalar/rank-one bytes, returns exact counts, preserves multi-call ordering, flushes per call, and keeps `eprint` diagnostics separate | Interpreter and development-compiler pipes/stdout emit pristine requested bytes without a result trailer; there is no rollback, persistent handle, or binary stdin. Broken-pipe timing is not a deterministic default-gate claim. |
| Bounded stdout copy | MLPL writes exact whole-file or subrange bytes through caller-capped reads/stdout calls with explicit total budgets and verified counts | Raw, canonical WAV, and checksum-verified Ogg page artifacts have clean binary stdout plus separate stderr narration; irreversible output has no cleanup transaction. |
| Bounded byte copy | MLPL copies exact whole-file or subrange bytes through caller-capped reads/appends, requires a new destination, verifies counts, and applies explicit keep/remove partial policy | Byte-identical output is executable at chunks 1, 7, 64, and 65,536; 64 MiB output peak RSS is measured separately below. |
| Bit operations | `band`, `bor`, `bxor`, `bnot`, `popcount`, `shl`, `shr`, `bits`, and `from_bits` pass golden vectors | In-memory endian and field work is unblocked in the interpreter. |
| Endian/layout library | MLPL codecs round-trip exact u8..u48 in both byte orders; width vectors extract MSB-first fields across byte boundaries | WAV-sized integers and MPEG headers need no format/runtime builtin; scalar u56/u64 remains intentionally rejected. |
| MPEG frame scanner | MLPL acquires synchronization with two compatible semantic headers, skips payloads by decoded frame length, reacquires after damage, and reports fixed bitrate/channel histograms plus frame-size statistics | Read-only MP3 ranges can be inspected under explicit byte and frame budgets; free bitrate and measured memory evidence remain out of scope. |
| ID3v2 inspector | MLPL parses bounded v2.3/v2.4 headers and frames, extended headers, padding and v2.4 footers; selected UTF-8/ASCII-compatible text is capped and unknown payloads are skipped by offset | Validated tag/audio descriptors are available without output writes; UTF-16, non-ASCII Latin-1, unsynchronization, compression and encryption remain explicit unsupported cases. |
| Bounded MP3 output | ID3 audio descriptors are copied byte-for-byte; MPEG ranges are validated, rescanned, and only confirmed Layer III frames are appended | Output state is fixed plus O(chunk size), damaged gaps are excluded, and compressed payload semantics are not decoded or validated. |
| Ogg page model | MLPL validates version-zero page headers, flags, lacing/body extents and budgets while retaining only lacing plus descriptors; granule positions remain exact split 32-bit words | Bounded page traversal is unblocked without native Ogg parsing; packet continuation and CRC verification remain separate steps. |
| Ogg packet reconstruction | MLPL folds lacing across consecutive single-serial pages, validates BOS/EOS, sequence and continuation state, and reports fixed-size packet statistics without payload reads | Read-only logical-stream packet boundaries are structurally bounded; multiplexing, payload reconstruction, and CRC remain explicit separate concerns. |
| Ogg CRC verifier | MLPL applies polynomial 0x04C11DB7 with the stored field logically zeroed and verifies pages through caller-capped chunks | Page integrity is visible and bounded without a native checksum implementation; cost is eight bit steps per page byte. |
| Bounded Ogg output | Accepted pages copy byte-for-byte or replace sequence bytes while streaming a virtual CRC and bounded rewritten chunks | Page payload/lacing remain unchanged and the new checksum verifies; this is a single-page primitive, not automatic logical-stream resequencing. |
| PCM WAV library | MLPL parses RIFF chunks, validates PCM mono/stereo 8/16-bit metadata/data, and canonically re-encodes tiny fixtures | Small-file WAV inspection/copy is unblocked; unknown chunks normalize away and whole-file f64 copies are not streaming. |
| Bounded WAV inspection | MLPL reads at most 16 header bytes per window, skips payloads by validated offsets, and matches whole-buffer metadata for every header split | Read-only WAV metadata scales structurally without sample retention; copy/write and measured-RSS claims remain separate. |
| Bounded WAV output | MLPL writes a fixed 44-byte canonical PCM header, then copies or inverts unsigned 8-bit samples through range-read/append chunks with exact output budgets | Payload state is O(chunk size); arbitrary RIFF ancillary chunks are intentionally normalized away, and file-path/interpreter boundaries remain. |
| Sparse-file peak RSS | Fixed-budget histogram and WAV consumers stayed below a 32 MiB ceiling as artifacts grew to 1 MiB and 64 MiB; repeat growth stayed at or below 1,081,344 bytes | The measured read-side high-water mark depends on chunk plus state, not total file size, on the recorded platform. |
| Growing-output peak RSS | A 1 MiB/64 MiB byte-copy pair at 65,536-byte chunks measured 15,859,712/15,974,400-byte peak RSS; `cmp` verified exact outputs | A 64-fold logical-output increase added 114,688 RSS bytes and stayed below a 48 MiB ceiling, supporting chunk-plus-state rather than output-sized retention. |
| Growing-stdout peak RSS | Redirected 1 MiB/64 MiB stdout at 65,536-byte chunks measured 12,533,760/15,892,480-byte peak RSS; `cmp` verified clean exact streams | A 64-fold output increase added 3,358,720 RSS bytes and stayed below a 48 MiB ceiling; stdout size did not drive resident retention. |
| Exact integer domain | Numeric arrays are f64-backed; `2^53` and mathematical `2^53+1` compare equal; bit operations reject operands at the upper domain boundary upstream | Byte and ordinary 32-bit field work is exact; 64-bit file fields require a split-word representation or a new type. |
| Script process surface | `args`, `read_stdin`, `read_stdin_chunk`, `print`, `eprint`, `write_stdout`, and `exit` lower; the compiled wc filter propagates chunk-read and stdout Results and uses status 2 for budget overflow | Whole-input text stdin remains available, while bounded raw-byte stdin is now accepted for the compiled wc pipe. Broader argument and application lowering remains partial. |
| Native numeric build | `reduce_add(iota(8))` produced `28` in both interpreter and compiled artifact | The native path is real for its supported numeric subset. The artifact runs directly; `otool -L` shows no named MLPL interpreter/parser/evaluator dynamic dependency. |
| Arithmetic build | `(iota(8) + 1) * 2` compiles and its reduction prints `72`, matching the interpreter | The prior generated-trait import defect is resolved in the selected adjacent development build; the gate now requires positive parity. |
| Application lowering | `args`, `arg`, `read_stdin`, `write_stdout`, whole/range `read_bytes`, `file_size`, append/write output, bit operations, functions, control flow, Results, records, `print`, `eprint`, and `exit` lower in the adjacent release compiler. `exit(7)` is clean; returned string/Result rendering still adds stdout text. | File/bit/process lowering has advanced, but pristine compiled streams, sink-error parity, and broader application operations still gate a useful CLI. |
| Compiled byte applications | Actual hexdump and histogram demos plus flattened controls pass source, function, control-flow, Result/record, byte-I/O, and bit lowering, then fail on unsupported `eq/2` | Neither application produces an artifact; comparison plus later array/text operations precede useful parity testing. |
| Compiled format applications | Actual bounded WAV copy/invert and Ogg copy/rewrite demos plus flattened controls reach the same unsupported `eq/2` boundary | No native format artifact exists to compare or memory-audit; generic operation lowering still blocks before RIFF/Ogg-specific parity is reached. |
| Isolated artifact audit | Numeric and partial-stdout artifacts run in a fresh source-free directory under an empty environment; dependency inspection finds no named MLPL parser/REPL/evaluator dynamic library | The compiler produces genuinely executable artifacts for its narrow subset. This control does not satisfy useful file-application acceptance because no byte/WAV/Ogg program compiles. |
| Standalone file application | Process, byte, format, and isolated-artifact gates are all executable; actual hexdump, histogram, WAV, and Ogg compilation is attempted | Not accepted. No useful file-processing artifact exists, and the ordered generic compiler/runtime unblock is recorded in the standalone report. |
| Unified media inspector | One argument-driven interpreter application dispatches bounded WAV, Ogg+CRC, MP3/ID3, and honest unknown input into a stable common summary; representative and error branches pass native mlplunit and exact narration oracles | A recognizable multi-format application is available now without codecs or compiler claims. It composes previously accepted bounded primitives and adds no new peak-RSS claim. |
| Structural media doctor | A five-case interpreter application classifies healthy WAV/Ogg/MP3, WAV normalization caveats, MP3 gap recovery, Ogg CRC/continuation rejection, unsupported/missing input, and unknown bytes with safe next actions | Structural evidence now drives conservative application policy without automatic repair or codec-validity claims; it composes existing bounded primitives and adds no new RSS claim. |
| WAV transforming application | Source/destination/mode/chunk arguments drive canonical copy or unsigned-8-bit inversion; output geometry is boundedly reparsed, previews are compared, canonical bytes pass `cmp`, and inverted payload is `[255,128,0]` | A real argument-driven interpreter transformation app is accepted with O(chunk) production payload state, new-destination safety, and explicit cleanup; it is not a codec or compiled executable. |
| Interpreter application portfolio | Inspector, doctor, WAV transformer, date index, wc, grep, du, and ls pass a combined 125-test/36-suite default gate plus exact narrated, host, and artifact oracles | Higher-level applications are accepted without weakening compiler, codec, binary-source, traversal, or measured-memory boundaries. |

## Claim boundaries

The repository can now truthfully claim:

- whole-file byte arrays and bounded offset/length reads;
- interpreter-side bit manipulation over exact non-negative f64 integers;
- script arguments, text stdin, separated output streams, and exit codes;
- a native compiler path for the tested numeric and arithmetic expressions;
- bounded seekable-file MPEG Layer III structural statistics, ID3v2.3/v2.4
  metadata/audio descriptors, ID3 stripping, and accepted-frame extraction
  without codec-decoding claims.
- bounded seekable-file Ogg page, single-stream packet-boundary, split-granule,
  CRC integrity, page copying, and sequence/CRC rewriting without codec claims.
- bounded interpreter-driven output to sandboxed file paths through validated
  append chunks, with measured resident growth independent of 64-fold output
  growth at the accepted chunk size.
- exact interpreter-driven binary stdout bytes through ordered, counted,
  per-call-flushed writes with diagnostics kept on stderr.
- an argument-driven interpreter media-inspection application with bounded
  format dispatch and structural WAV/Ogg/MP3 evidence.
- a structural media-doctor application that distinguishes permitted bounded
  operations from rejection and unknown input.
- an argument-driven bounded WAV copy/inversion application producing verified
  real artifacts through the interpreter file-path sink.

It cannot yet claim:

- packed `u8` storage or one byte of resident data per file byte;
- incremental binary input, stream handles, backpressure, or codec state;
- persistent source/sink handles, binary stdin, backpressure control, or
  cross-call output transactions;
- exact scalar representation of arbitrary 64-bit file fields;
- complete interpreter/compiler parity for byte I/O, process APIs, or bit operations;
- compilation of a useful file-processing application;
- compiler lowering/entry-point behavior for byte I/O, remaining process APIs, or bit operations needed by a
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

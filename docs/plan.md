# File Processing Demo Delivery Plan

## Mission and proof standard

Demonstrate that sw-MLPL can inspect, transform, and stream real file data while
using its APL-inspired array operations where they are strongest, and can
eventually compile the application into an ordinary standalone executable.
The repository is a forcing function for general byte, stream, runtime, and
compiler capabilities; MP3-to-Ogg is the capstone, not the starting point.

Every deliverable identifies its implementation layer:

1. **MLPL implementation** — MLPL owns parsing, analysis, transformation, or
   orchestration.
2. **Generic runtime capability** — Rust supplies representation or effects
   such as byte buffers, bounded file I/O, streams, and process arguments while
   preserving interpreter/compiler parity.
3. **Codec extension** — a documented Rust boundary supplies a mature decoder
   or encoder while MLPL owns the visible pipeline and array transforms.
4. **External oracle** — a named tool validates output or provides an explicit
   fallback; it is never presented as MLPL implementation.

Claims require executable evidence against the configured sw-MLPL binary.
Research notes and adjacent documentation are hypotheses until probed.

## Two complementary capability tracks

### File-data track

`bytes -> bits -> fields -> records -> chunks -> streams -> containers -> codecs`

- Small inputs should support convenient whole-buffer array operations.
- Large inputs must use bounded memory independent of file size.
- Chunk boundaries must not change results, including boundaries inside a
  multibyte integer, bit field, record, tag, frame, page, or packet.
- Read/parse/transform/serialize/write paths need round-trip invariants.

### Application-delivery track

`REPL -> script -> CLI parity -> compiled native application`

- Interpreter and compiled code should expose the same generic operations.
- A real CLI needs arguments, stdout/stderr, exit status, binary input/output,
  and deterministic errors.
- The preferred endpoint is generated Rust linked to shared runtime and
  extension crates, without shipping the parser, REPL, or source.
- An interpreter/bootstrap bundle is only a clearly labeled compatibility
  fallback, not the graduation criterion.

## Current boundary to verify

The configured sw-MLPL has whole-file `read_bytes`/`write_bytes`, bounded
`read_bytes(path, offset, length)`, `file_size`, f64-backed exact-integer byte
values, fixed-width bit operations, and interpreter-side CLI facilities. Its
native build path works for the tested numeric and arithmetic expressions and
partially lowers `args`/`arg`/`write_stdout`, but the generated wrapper
contaminates binary stdout with a textual result line, invalid bytes are
coerced instead of rejected, write errors are discarded, and stdin/stderr/exit,
byte reads/appends, and bit operations are not lowered. Packed `u8` arrays,
incremental binary sources/sinks, broad application lowering, and extension
linking remain absent or incomplete. See [the measured baseline](capabilities.md).

The repository must distinguish:

- logical byte values from physically packed byte storage;
- whole-file chunking after materialization from true bounded reads;
- an MLPL-controlled pipeline from a shell command that delegates the job;
- successful compilation from a genuinely self-contained useful application.

## Architecture direction

```text
path / stdin / args
        |
        v
bounded byte source ---> whole-buffer adapter
        |                       |
        +----------+------------+
                   v
          MLPL parse/transform/reduce
                   |
          +--------+---------+
          |                  |
   generic runtime      codec extension
          |                  |
          +--------+---------+
                   v
        bounded byte sink / stdout
                   |
          interpreter or compiler
```

Generic capabilities belong in a shared runtime usable by both evaluator and
generated Rust. Format-specific constructs—ID3, WAV, MP3, Ogg, Vorbis—belong in
libraries. Codec extensions should expose chunk-oriented PCM/packet interfaces,
not opaque whole-command transcoding.

## Delivery phases

### Phase 0 — repository and measured capability contract

- Establish Agentrail instructions, license/link/source checks, thin `just`
  workflows, fixture conventions, binary selection, a demo catalog, and the
  peer-standard README copyright/license section.
- Make mlplunit the only executable MLPL test path: configure root discovery,
  native `@test` registration, shared assertions, human/TAP/list/filter modes,
  and an adoption audit in the full check gate.
- Probe byte I/O, byte representation, bit operations, exact-integer limits,
  range/seek/stream APIs, CLI access, compiler lowering, and runtime contents.
- Record observed interpreter/compiler parity and smallest upstream needs.

Acceptance: `just check` is deterministic; every planned claim is marked
executable, gated, extension-backed, or external.

### Phase 1 — in-memory binary foundations

- Build hexdump and byte-histogram demos over tiny generated fixtures.
- Add endian integer decode/encode and declarative bit-field helpers.
- Inspect and canonically copy a minimal PCM WAV file.
- Test `decode(encode(x)) == x`, known byte/field vectors, malformed lengths,
  integer boundaries, and canonical byte-identical round trips.

Acceptance: MLPL visibly performs the array analysis and parsing; current
physical representation and copy costs are documented without streaming claims.

### Phase 2a — bounded range analysis

Status: accepted. See the [bounded-read report](bounded-read-report.md).

- Add range-reader conformance for EOF, offsets, lengths, overflow, permissions,
  and sandbox escape attempts.
- Add chunk-invariant histogram/reduction and bounded WAV inspection.
- Exercise chunk sizes 1, 7, 64, and 65,536 plus boundaries within fields.
- Add a sparse input larger than the configured memory budget and measure peak
  resident memory using a documented method.

Acceptance: read-side results match whole-buffer references and measured peak
memory is bounded by documented state plus chunk size, not total file size.

### Phase 2b — incremental binary output

Status: accepted for sandboxed file-path outputs. Binary stdout is accepted
separately in Phase 2c through `write_stdout`. See the
[bounded-output report](bounded-output-report.md) and
[sink conformance contract](append-bytes.md). Binary stdin/source handles and
compiled parity remain separate gates.

- Add sink conformance and chunked byte-copy tests.
- Add bounded WAV copy and a simple PCM array transformation.
- Strip/sanitize ID3 tags, extract raw MPEG frames, and rewrite Ogg pages from
  descriptors earned by the read-only sagas.
- Verify byte/hash oracles across chunk sizes and output error paths.
- Measure peak resident memory for output larger than the configured budget.

Acceptance: copy/transformation output matches the reference path and peak
memory is bounded independently of total input and output size.

### Phase 2c — binary stdout output

Status: accepted for interpreter-driven seekable-file pipelines. See the
[stdout acceptance report](stdout-report.md) and
[stdout conformance contract](write-stdout.md).

- Validate exact byte/count/order/error behavior and stderr separation.
- Add bounded raw, PCM WAV, and CRC-preflighted Ogg stdout applications.
- Measure exact 1 MiB and 64 MiB captured output under fixed RSS ceilings.

Acceptance: stdout is pristine binary, narration is separate, captured
artifacts match independent oracles, and retained memory remains bounded as
output grows. Binary stdin/source handles and compiler parity remain separate.

### Phase 3 — MP3 and ID3 inspection

Status: accepted. See the [MP3/ID3 read-only report](mp3-id3-report.md).

- Parse MPEG audio frame headers as data-described bit fields.
- Scan frames and report version/layer, duration, sample rate, bitrate range and
  histogram, channel modes, and frame sizes without decoding audio.
- Parse bounded ID3 metadata and emit validated tag/audio range descriptors for
  later output work.
- Validate against tiny redistributable fixtures and an explicit oracle.

Acceptance: parsing survives arbitrary input chunking and malformed sync/tag
data; statistics and descriptors match explicit oracles without output claims.

### Phase 4 — Ogg container inspection

Status: accepted. See the [Ogg read-only report](ogg-report.md).

- Parse Ogg pages, lacing values, packet continuation, granule positions,
  serial/sequence fields, and 64-bit values.
- Implement Ogg CRC calculation visibly in MLPL where practical.
- Verify stored/computed CRC checks and emit validated page descriptors for
  later rewriting.

Acceptance: packet reconstruction is chunk-invariant; golden CRC vectors and
oracle comparisons pass; unsupported codecs remain inspectable at container
level without output claims.

### Phase 5 — native application compilation

Gate: compiler/runtime support exists for the generic application surface
proven necessary by earlier phases.

Status: assessed and not accepted. The
[standalone report](standalone-report.md) records partial process lowering,
actual/flattened application failures, and the isolated artifact control. No
useful file-processing artifact is currently produced.

- Compile hexdump, histogram, and at least one inspector/copy tool.
- Verify arguments, binary stdin/files/stdout, stderr, exit codes, errors, and
  interpreter/compiler output parity.
- Inspect the artifact and execute it in a clean environment to establish that
  it does not require MLPL source, parser, REPL, or interpreter at runtime.

Acceptance: a useful file-processing CLI passes the same fixture suite in
interpreted and compiled modes and is honestly documented as standalone.

### Phase 6 — audio codec extension and capstone

- Define chunk-oriented decoder/encoder extension contracts and lifecycle,
  error, backpressure, flush, metadata, sample-format, and channel semantics.
- Decode MP3 to PCM through a Rust extension; perform a visible MLPL waveform,
  gain, or windowed RMS transform; encode Vorbis and packetize Ogg.
- Compose the full MP3-to-Ogg CLI and compile it as a standalone application.
- Use a pinned external decoder/analyzer only as an oracle for duration,
  channels, sample rate, decoded PCM comparison, and output validity.

Acceptance: inputs larger than memory transcode with a measured bounded high-
water mark; the MLPL-owned pipeline and transform are visible; output is valid
Ogg/Vorbis; failures are deterministic; the native artifact meets Phase 5.

## Cross-cutting gates

- Default tests use tiny, generated or clearly redistributable fixtures. Large
  and external-oracle tests are opt-in with exact prerequisites and checksums.
- All executable MLPL tests run through mlplunit. Demos can be independently
  self-checking, but direct interpreter scripts do not count as test coverage.
- Parsers validate sizes, offsets, counts, allocation limits, integer exactness,
  and output budgets before allocation or iteration.
- Tests cover empty, truncated, malformed, unsupported, overflow, short-I/O,
  and adversarial sync inputs as applicable.
- Each demo records ownership layer, logical complexity, actual allocation/copy
  behavior, and remaining explicit loops or missing combinators.
- Format and codec implementation work cites authoritative specifications;
  the research transcript is design input, not normative evidence.
- No saga modifies `../sw-mlpl`. Evidence-backed upstream changes require
  explicit authorization and their own repository saga.
- A blocked step records the failed acceptance criterion, executable evidence,
  attempted alternatives, and smallest unblock action. Each successful step
  closes with the next highest-value unblocked step and any gate on it.

## Recommended order

The foundation, bounded range-analysis, MP3/ID3 inspection, and Ogg inspection
sagas are accepted; see their [foundation](foundation-report.md),
[bounded-read](bounded-read-report.md), [MP3/ID3](mp3-id3-report.md), and
[Ogg](ogg-report.md), and [bounded-output](bounded-output-report.md) reports.
The standalone-file-application assessment is complete with a blocked verdict.
The active unblocked downstream sequence builds higher-level interpreter media
applications: the [unified bounded inspector](media-inspector.md),
[structural media doctor](media-doctor.md), and
[bounded WAV transforming tool](wav-transform-app.md) are accepted; see the
[combined acceptance report](interpreter-media-apps-report.md). Separately,
rerun standalone executable
change detectors when
upstream source loading, application lowering, byte I/O, and process parity
change. Binary stdout remains accepted in the interpreter; binary stdin/source
handles remain separate. Codec-extension prototyping may proceed against
seekable interpreter file paths when separately authorized, but standalone
MP3-to-Ogg remains gated on compiler parity.

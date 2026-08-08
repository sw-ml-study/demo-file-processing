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
native build path works for a narrow numeric expression, but a documented
arithmetic case currently fails generated-Rust compilation and byte, bit, and
argument builtins are not lowered. Packed `u8` arrays, incremental binary
sources/sinks, broad application lowering, and extension linking remain absent
or incomplete. See [the measured baseline](capabilities.md).

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

### Phase 2 — bounded file processing

Gate: bounded range reads are available. Read-only chunk work may proceed;
steps requiring bounded output remain gated until an incremental binary sink is
available through separately authorized upstream work.

- Add chunk-invariant histogram/reduction and bounded WAV copy/transformation.
- Exercise chunk sizes 1, 7, 64, and 65,536 plus boundaries within fields.
- Add sparse inputs larger than the configured memory budget and measure peak
  resident memory using a documented method.
- Verify error semantics for EOF, short reads/writes, offset overflow,
  permissions, and sandbox escape attempts.

Acceptance: results match whole-buffer reference paths and measured peak memory
is bounded by documented state plus chunk size, not total file size.

### Phase 3 — MP3 and ID3 inspection/manipulation

- Parse MPEG audio frame headers as data-described bit fields.
- Scan frames and report version/layer, duration, sample rate, bitrate range and
  histogram, channel modes, and frame sizes without decoding audio.
- Parse bounded ID3 metadata, strip or sanitize tags, and extract raw compatible
  MPEG frames through a streaming transformation.
- Validate against tiny redistributable fixtures and an explicit oracle.

Acceptance: parsing survives arbitrary input chunking and malformed sync/tag
data; writing preserves untouched audio frame bytes.

### Phase 4 — Ogg container processing

- Parse Ogg pages, lacing values, packet continuation, granule positions,
  serial/sequence fields, and 64-bit values.
- Implement Ogg CRC calculation visibly in MLPL where practical.
- Verify, copy, and minimally rewrite pages with stored/computed CRC checks.

Acceptance: packet reconstruction is chunk-invariant; golden CRC vectors and
page round trips pass; unsupported codecs remain inspectable at container level.

### Phase 5 — native application compilation

Gate: compiler/runtime support exists for the generic application surface
proven necessary by earlier phases.

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

Start with the `file-processing-foundations` saga in [sagas.md](sagas.md).
It creates the repository gate, measures the language/runtime/compiler rather
than trusting assumptions, and delivers useful in-memory byte/field/WAV demos.
The measured range API already removes the original read-side blocker; finish
the in-memory foundations next, then use their evidence to minimize the
remaining incremental-write/compiler requests. This isolates file-processing
needs from codec complexity and keeps later extension work evidence-driven.

# Agentrail Saga Queue

Only one saga is active at a time. Initialize a later saga only after the
preceding saga is completed and archived. Each step is independently
reviewable. Add newly discovered work with Agentrail commands rather than
editing durable `.agentrail/` state by hand.

## Saga 1 — `file-processing-foundations`

1. `repository-check-gate` — add thin `just check` delegation, deterministic
   license/link/source checks, fixture/catalog conventions, and documented MLPL
   binary selection without installation; configure root mlplunit discovery,
   wrappers, shared native-test conventions, and an adoption audit.
2. `capability-probe` — measure byte read/write representation, bit operations,
   exact-integer limits, bounded/range/stream APIs, CLI facilities, native build
   lowering, and interpreter/compiler parity.
3. `hexdump-and-histogram` — add self-checking whole-buffer hexdump and byte
   histogram demos with generated edge-case fixtures.
4. `endian-and-bit-fields` — implement golden-tested integer endian codecs and
   declarative field extraction across byte boundaries.
5. `wav-inspect-and-copy` — inspect and canonically round-trip a tiny PCM WAV,
   including malformed-length and unsupported-format cases.
6. `foundation-contract-report` — run the full gate, report ownership/copy and
   capability evidence, and write the smallest bounded-I/O/compiler upstream
   contracts needed to unblock later sagas.

## Saga 2 — `bounded-file-streaming`

Gate: bounded range reads are already verified. Read-only steps are unblocked;
bounded-copy/transformation steps require a separately authorized incremental
binary sink if whole-output materialization violates their acceptance bound.

1. Bounded reader/writer conformance, sandbox, EOF, short-I/O, and overflow tests.
2. Chunk-boundary invariant histogram and reduction.
3. Streaming WAV copy and a simple PCM array transform.
4. Sparse file larger than the memory budget with measured peak RSS.
5. Streaming acceptance report and downstream API stabilization.

## Saga 3 — `mp3-id3-tools`

1. MPEG audio frame-header bitfield vectors and parser.
2. Resynchronizing frame scanner and deterministic MP3 statistics.
3. Bounded ID3v2 header/frame parsing with text/size limits.
4. Tag strip/sanitize and raw MPEG-frame extraction with byte preservation.
5. MP3/ID3 oracle comparison and malformed-input report.

## Saga 4 — `ogg-container-tools`

1. Ogg page and lacing parser with 64-bit field handling.
2. Cross-page packet reconstruction and continuation tests.
3. MLPL-visible Ogg CRC golden vectors and verifier.
4. Canonical page copy/rewrite with recomputed CRC.
5. Container acceptance report and codec-extension requirements.

## Saga 5 — `standalone-file-applications`

Gate: separately authorized compiler/runtime work provides the generic CLI and
I/O surface demonstrated necessary by Sagas 1–4.

1. CLI argument, stdin/stdout/stderr, exit-status, and error conformance.
2. Compile hexdump/histogram and verify interpreter/compiler parity.
3. Compile a WAV or Ogg inspector/copy tool with binary I/O parity.
4. Clean-environment artifact audit proving no source/parser/REPL dependency.
5. Standalone application capability report.

## Saga 6 — `audio-codec-extensions`

1. Chunk-oriented PCM/packet codec extension contract and test double.
2. Rust MP3 decoder extension integration and golden PCM validation.
3. MLPL waveform or windowed-RMS processing over decoded PCM chunks.
4. Rust Vorbis encoder extension and Ogg packetization integration.
5. Backpressure, flush, metadata, malformed-stream, and bounded-memory tests.

## Saga 7 — `mp3-to-ogg-capstone`

1. Compose the MLPL-owned decode/transform/encode/write pipeline.
2. Add CLI behavior, deterministic diagnostics, and cleanup/error tests.
3. Validate audio/container output against pinned external oracles.
4. Prove large-input bounded memory and document performance methodology.
5. Compile and audit the standalone native MP3-to-Ogg application.

## Cross-saga rules

- Work and publish directly on `main` using only named `git add`, detailed
  `git commit`, and `git push origin main`; never use branches or `gh`.
- Use mlplunit for every executable MLPL test; preserve native `@test`
  discovery and shared assertions as a repository-wide gate.
- Do not modify `../sw-mlpl`; upstream work requires separate authorization.
- Do not claim streaming from whole-file materialization, packed bytes from
  f64-backed values, or a standalone binary from an interpreter wrapper.
- Do not hide substantive work behind `ffmpeg`; external tools are optional,
  named validation oracles only.
- Close a saga only when the full gate passes and acceptance evidence plus
  limitations are reflected in user-facing documentation.
- On blockage, record the exact failed criterion, evidence, attempts, and
  smallest unblock action. On completion, identify the next highest-value
  unblocked step and any gate before stopping.

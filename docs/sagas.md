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

## Saga 2 — `bounded-range-analysis`

Status: accepted; see [bounded-read evidence](bounded-read-report.md).

1. Range-reader conformance for sandbox, EOF, offsets, lengths, and overflow.
2. Chunk-boundary invariant histogram and reduction.
3. Range-based WAV inspection with headers split at every relevant boundary.
4. Sparse input larger than the memory budget with measured peak RSS.
5. Self-describing output audit for every user-facing demonstration.
6. Bounded-read acceptance report and downstream API stabilization.

## Saga 3 — `mp3-id3-inspection`

Status: accepted; see the [MP3/ID3 read-only report](mp3-id3-report.md).

1. Reusable MPEG audio frame-header model and golden semantic vectors.
2. Bounded resynchronizing frame scanner and deterministic MP3 statistics.
3. Bounded ID3v2 header/frame parsing with text and size limits.
4. Chunk-invariance, malformed-input, and explicit oracle comparisons.
5. Read-only MP3/ID3 acceptance report and output descriptors for later writes.

## Saga 4 — `ogg-container-inspection`

Status: accepted; see the [Ogg read-only report](ogg-report.md).

1. Bounded Ogg page/lacing parser using split exact words for 64-bit fields.
2. Cross-page packet reconstruction and continuation tests.
3. MLPL-visible Ogg CRC golden vectors and verifier.
4. Chunk-invariance, malformed-input, and explicit oracle comparisons.
5. Read-only container report and rewrite descriptors for later output work.

## Saga 5 — `incremental-binary-output`

Status: accepted; see the [bounded-output report](bounded-output-report.md).
Binary stdout is proceeding in the separate `binary-stdout-output` saga;
compiled parity remains gated.

1. `append_bytes` conformance including validation, counts, implicit per-call
   close/flush, path errors, initialization, and partial-output policy.
2. Chunked copy with byte-identical and hash oracles.
3. Bounded WAV copy and a simple PCM array transform.
4. ID3 tag strip/sanitize and raw MPEG-frame extraction with byte preservation.
5. Ogg page copy/rewrite with recomputed CRC.
6. Large-output peak RSS and bounded-output acceptance report.

## Saga 5b — `binary-stdout-output`

Status: accepted; see the [stdout acceptance report](stdout-report.md).

1. `write_stdout` byte/count/validation/stderr/compiler-boundary conformance.
2. Bounded seekable-file to clean binary-stdout loops and demonstrations.
3. Growing-output RSS acceptance and documentation reconciliation.

## Saga 6 — `standalone-file-applications`

Gate: separately authorized compiler/runtime work provides the generic CLI and
I/O surface demonstrated necessary by Sagas 1–4.

Status: assessed; not accepted because byte and format applications are blocked
before artifact production. See the
[compiled process conformance report](compiler-process-conformance.md) and
[compiled byte-application report](compiled-byte-applications.md).
The bounded WAV/Ogg artifact attempt reaches the same blocker; see the
[compiled format-application report](compiled-format-applications.md).
The [standalone artifact audit](standalone-artifact-audit.md) validates the
audit method on narrow compiler controls, but remains blocked for a real file
application because no such artifact is produced.
The consolidated verdict and ordered unblock are in the
[standalone application assessment](standalone-report.md).

1. CLI argument, stdin/stdout/stderr, exit-status, and error conformance.
2. Compile hexdump/histogram and verify interpreter/compiler parity.
3. Compile a WAV or Ogg inspector/copy tool with binary I/O parity.
4. Clean-environment artifact audit proving no source/parser/REPL dependency.
5. Standalone application capability report.

## Saga 6b — `interpreter-media-apps`

Status: active. The [unified media inspector](media-inspector.md) composes the
accepted bounded WAV, Ogg/CRC, and MP3/ID3 primitives into an argument-driven
application while retaining an honest unknown branch and interpreter boundary.
The [structural media doctor](media-doctor.md) adds healthy/warning/rejected/
unknown policy and safe next actions over the same evidence.
The [bounded WAV transformation app](wav-transform-app.md) adds argument-driven
canonical copy and unsigned-8-bit inversion with exact artifact verification.

1. Unified bounded media inspector.
2. Structural media doctor with warnings and safe next actions.
3. Argument-driven bounded WAV or Ogg transforming tool.
4. Interpreter-application acceptance and documentation reconciliation.

## Saga 7 — `audio-codec-extensions`

1. Chunk-oriented PCM/packet codec extension contract and test double.
2. Rust MP3 decoder extension integration and golden PCM validation.
3. MLPL waveform or windowed-RMS processing over decoded PCM chunks.
4. Rust Vorbis encoder extension and Ogg packetization integration.
5. Backpressure, flush, metadata, malformed-stream, and bounded-memory tests.

## Saga 8 — `mp3-to-ogg-capstone`

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

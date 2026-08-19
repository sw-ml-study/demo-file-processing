# Interpreter media applications acceptance

## Verdict

Accepted as **interpreter applications**. The repository now demonstrates that
its bounded format primitives compose into recognizable, argument-driven
inspection and transformation workflows while standalone compilation remains
independently blocked.

The accepted slice contains:

1. a unified bounded WAV/Ogg/MP3/unknown inspector;
2. a structural media doctor with conservative safe next actions; and
3. a bounded canonical WAV copy/unsigned-8-bit inversion tool producing real
   verified artifacts.

None is described as decoded compressed audio, automatic repair, a native codec
application, or a standalone compiled executable.

## Application matrix

| Application | Demonstrable output | Executable acceptance |
|---|---|---|
| `just media-inspect [path]` | Detection evidence, stable common summary, WAV PCM facts, Ogg serial/lacing/CRC, MP3 ID3/frame/rate facts, or honest unknown classification | Representative WAV/Ogg/MP3, chunk invariance, empty/unknown, truncated ID3/Ogg, bad Ogg CRC, unsupported ID3, missing/sandbox paths, and invalid budgets |
| `just media-doctor` | Healthy MP3, WAV normalization warning, damaged-MP3 recovery warning, Ogg continuation rejection, and unknown bytes—each with reason and safe next action | Healthy WAV/Ogg/MP3, ancillary chunks, skipped/resynchronized frames, Ogg continuation/CRC, unsupported ID3, missing input, unknown input, and chunk invariance |
| `just wav-transform [source] [destination] [mode] [chunk-size]` | Real canonical WAV artifact, arguments, layout and chunk facts, before/after sample previews, cleanup policy, and interpretation | Exact canonical `cmp`, semantic normalization, inversion payload `[255,128,0]`, chunks 1/2/7/65,536, existing-destination preservation, invalid mode/budget/source errors |

Every demo names MLPL-owned work, native runtime effects, allocation behavior,
interpretation, and boundaries. Tests remain terse; applications narrate why
their outputs matter.

## Ownership and memory

MLPL owns signature dispatch, RIFF/Ogg/ID3/MPEG parsing, endian and bit work,
CRC, packet/frame reasoning, health policy, transformation decisions, canonical
header encoding, bounded traversal, and verification.

The native interpreter runtime owns file metadata, bounded offset/length reads,
and sandboxed append effects. No native media parser, repair library, decoder,
encoder, ffmpeg, or ffprobe participates in the accepted default applications.

The applications compose previously measured bounded primitives:

- inspector/doctor retain fixed descriptors plus bounded read windows;
- WAV transformation retains fixed header/metadata plus O(chunk size) payload
  state and at most eight preview bytes; and
- tiny test fixtures may be read completely as independent test-only oracles.

No new peak-RSS number is claimed. Existing sparse read, growing file-output,
and growing stdout measurements remain the evidence for the underlying
primitives.

## Verification

The final `just check` gate passes:

- 125 native mlplunit tests across 36 suites;
- all three application narration/artifact oracles;
- exact process and interpreter binary-stdout contracts;
- byte, WAV, MP3/ID3, Ogg page/packet/CRC, bounded file/stdout output, and demo
  oracles;
- compiler numeric/arithmetic and partial process probes;
- expected-failure compilation change detectors for real byte/WAV/Ogg apps;
  and
- isolated source-free native control-artifact execution/dependency inspection.

## Remaining blockers

### Standalone compiler parity

The applications still run through `mlpl-repl`. sw-MLPL has recorded the
downstream contract and queued the missing rungs in measured order:

1. B0 source-relative include loading;
2. B1 user functions plus Results/records;
3. C control flow;
4. D bounded byte/file I/O with shared validation and error propagation;
5. D2 clean process/stdout/stderr/exit semantics; and
6. E bit operations followed by positive artifact parity.

Saga A (`CVal`, strings, `args`/`arg`/`write_stdout`) is shipped. B0–E are queued,
not delivered; downstream expected-failure probes remain active.

### Binary source lifecycle

Binary stdin, consumable source handles, persistent handles, explicit
backpressure, and cross-call transactions remain absent. They are not required
for these seekable-file applications, but are required for honest stdin-driven
streaming and later codec pipelines.

### Codec extensions

MP3 decoding and Vorbis encoding still require separately authorized
chunk-oriented extension contracts and implementations. Container and frame
inspection, confirmed-frame extraction, WAV PCM transformation, and Ogg page
work do not imply codec support.

Packed u8 storage remains a density/performance roadmap item rather than a
bounded-memory blocker. Arbitrary exact 64-bit fields continue to use split
words where required.

## Recommended next action

Maintain these interpreter applications and rerun `just check` against rebuilt
development compilers; the expected-failure probes identify the first newly
unblocked positive parity step. Independently, a later authorized application
slice could wrap the existing Ogg sequence/CRC rewrite or MP3 confirmed-frame
extraction primitives, but the current three-app objective is complete.

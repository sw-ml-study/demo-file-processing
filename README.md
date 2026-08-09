# demo-file-processing

Practical file-inspection, transformation, and streaming demonstrations
written in [sw-MLPL](https://github.com/sw-ml-study/sw-mlpl). The project asks
whether an APL-inspired array language can process real byte-oriented formats,
scale beyond whole-file memory, and compile a useful command-line application
into a standalone native executable.

The progression begins with hexdump, byte statistics, endian fields, and WAV
round trips; continues through bounded range analysis, MP3/ID3 inspection, and Ogg
pages/CRC; and ends with MP3-to-Ogg as an extension-backed capstone. Native and
external components must be named explicitly—MLPL ownership is never implied
when a runtime, codec extension, or validation oracle performs the work.

## Project status

The foundation, bounded range analysis, MP3/ID3 inspection, and read-only Ogg
inspection are accepted with 68 native mlplunit tests across 21 suites. See
[the Ogg acceptance report](docs/ogg-report.md),
[the MP3/ID3 acceptance report](docs/mp3-id3-report.md),
[the bounded-read acceptance report](docs/bounded-read-report.md),
[the foundation acceptance report](docs/foundation-report.md),
[the development guide](docs/development.md),
[the measured capability baseline](docs/capabilities.md),
[the upstream contracts](docs/upstream-contract.md), and
[the delivery plan](docs/plan.md)
for architecture and acceptance gates, [the saga queue](docs/sagas.md) for the
recommended implementation order, and
[the research transcript](docs/sw-mlpl-demo-file-processing-research.txt) for
the original design discussion.

Bounded range reads and incremental sandboxed file-path writes are available,
but packed byte storage, binary stdin/stdout streams, and compiled application
APIs are not current claims. The
native compiler handles the tested numeric and arithmetic cases; unsupported
byte/process/bit lowering remains tracked explicitly.

## What runs now

Every user-facing recipe below follows the
[demonstration output contract](docs/demo-output.md): it describes its purpose,
input, MLPL/native ownership, operation, and how to interpret the result.
Repository tests and audits remain terse validation tools rather than demos.

The [whole-buffer byte foundations](docs/byte-foundations.md) provide reusable
MLPL validation, hexadecimal formatting, and a 256-bin array-oriented byte
histogram. The hexdump demonstrates a 16-byte formatting boundary; the
histogram proves one count for every byte value. Both use tiny generated
fixtures and state their current f64 representation and copy costs explicitly.

The [bounded range-reader contract](docs/bounded-range-reader.md) validates
exact offsets and chunk budgets, advances immutable read state, and preserves
runtime sandbox and filesystem errors. It is executable conformance evidence,
not yet a bounded-memory demo claim.

The [bounded histogram](docs/bounded-histogram.md) merges 256-bin MLPL results
across arbitrary ranges and matches the whole-buffer oracle for chunk sizes 1,
7, 64, and 65,536. Its structurally chunk-bounded allocation is backed by the
opt-in sparse-file peak-RSS evidence below.

The [endian and field-layout slice](docs/endian-and-fields.md) adds exact
one-to-six-byte little/big-endian codecs and data-described MSB-first field
extraction. Its narrated demo decodes a golden four-byte MPEG audio header,
including fields that cross byte boundaries, entirely in MLPL. The
[semantic Layer III model](docs/mpeg-audio-header.md) contrasts MPEG-1 and the
de-facto MPEG-2.5 extension, derives rates/samples/frame lengths, and rejects
reserved or indeterminate free-bitrate headers.

The bounded [MPEG scanner](docs/mpeg-frame-scanner.md) and
[ID3v2 inspector](docs/id3v2-inspection.md) have narrated VBR,
resynchronization, metadata, audio-range, and malformed-tag demonstrations.
Their [tiny fixtures and pinned oracle](docs/mp3-fixtures-oracle.md) distinguish
synthetic structural evidence from a decodable 440 Hz tone and opt-in ffprobe
validation.

The bounded [Ogg page](docs/ogg-page-model.md),
[cross-page packet](docs/ogg-packet-reconstruction.md), and
[visible CRC](docs/ogg-crc.md) slices have narrated structural, continuation,
and corruption contrasts. Their [fixtures and pinned Ogg/Opus
oracle](docs/ogg-fixtures-oracle.md) separate container packet counts from
codec-decoded audio packets.

The [PCM WAV slice](docs/wav.md) inspects RIFF chunks and canonically copies
empty/minimal mono files. It validates padding, lengths, derived rates, formats,
and budgets while distinguishing byte-identical canonical round trips from
semantic normalization of files containing unknown chunks.

The [bounded WAV inspector](docs/wav-range-inspection.md) reads only RIFF,
chunk, and PCM format headers through bounded ranges, skips sample payloads by
validated offsets, and matches whole-buffer metadata across every relevant
header split. It does not claim bounded copying or transformation.

The opt-in [sparse-file memory evidence](docs/sparse-memory-evidence.md)
measures fixed-budget histogram and WAV consumers as sparse artifacts grow to
1 MiB and 64 MiB. Recorded macOS peak RSS stayed below 32 MiB, with growth
between zero and roughly 1.1 MiB across repeated small/large comparisons.

```sh
just hexdump
just histogram
just bounded-histogram
just binary-fields
just mp3-scan
just id3-inspect
just mp3-oracle
just ogg-pages
just ogg-packets
just ogg-crc
just ogg-oracle
just wav-inspect-copy
just wav-range-inspect
just sparse-memory-evidence
just tests tests/bytes
just tests tests/io
just tests tests/binary
just tests tests/wav
just check
```

## Development and testing

The repository uses a thin root `justfile` over portable scripts, with
`just check` as the required pre-commit gate. Tool selection will honor
`MLPL=/absolute/path/to/mlpl-repl` and
`MLPLUNIT=/absolute/path/to/mlplunit`; scripts may use documented adjacent
development checkouts but never install or overwrite either tool.

All executable MLPL tests use
[mlplunit](https://github.com/softwarewrighter/mlplunit), a root
`mlplunit.conf`, and `test_*.mlpl` discovery. Each suite registers native
`@test` cases, uses mlplunit's shared assertions, and calls
`u:run_registered_tests()`. The test wrapper supports normal, TAP, listing,
path, and filter modes. Standalone demos may remain self-checking, but ad hoc
test scripts or direct interpreter execution will not substitute for mlplunit
coverage.

## Planned repository shape

```text
src/          reusable MLPL parsing and transformation code
demos/        readable standalone file-processing applications
tests/        native mlplunit suites mirroring source/demo domains
fixtures/     tiny deterministic generated or redistributable inputs
catalog/      validated demo and test inventories
scripts/      portable execution and validation harnesses
docs/         research, plans, capability evidence, and upstream contracts
```

## Copyright and license

Copyright (c) 2026 Michael A Wright. See [COPYRIGHT](COPYRIGHT).

This project is available under the [MIT License](LICENSE).

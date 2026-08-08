# demo-file-processing

Practical file-inspection, transformation, and streaming demonstrations
written in [sw-MLPL](https://github.com/sw-ml-study/sw-mlpl). The project asks
whether an APL-inspired array language can process real byte-oriented formats,
scale beyond whole-file memory, and compile a useful command-line application
into a standalone native executable.

The progression begins with hexdump, byte statistics, endian fields, and WAV
round trips; continues through bounded streaming, MP3/ID3 inspection, and Ogg
pages/CRC; and ends with MP3-to-Ogg as an extension-backed capstone. Native and
external components must be named explicitly—MLPL ownership is never implied
when a runtime, codec extension, or validation oracle performs the work.

## Project status

This repository has its initial validation and native-test foundation. See
[the development guide](docs/development.md),
[the delivery plan](docs/plan.md)
for architecture and acceptance gates, [the saga queue](docs/sagas.md) for the
recommended implementation order, and
[the research transcript](docs/sw-mlpl-demo-file-processing-research.txt) for
the original design discussion.

Large-file streaming and standalone-application support are targets, not
current claims. The first implementation saga will probe the configured
sw-MLPL interpreter/compiler and turn observed gaps into minimal upstream
contracts before relying on them.

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

set shell := ["sh", "-cu"]

# Show available repository tasks.
default:
    @just --list

# Run structural, policy, catalog, fixture, and documentation audits.
audit:
    ./scripts/audit

# Run all native mlplunit tests; extra arguments select paths or filters.
tests *args:
    ./scripts/run-tests {{args}}

# Emit native test results as TAP.
tap *args:
    ./scripts/run-tests --format tap {{args}}

# List tests discovered by mlplunit without executing them.
list-tests:
    ./scripts/run-tests --list

# Print selected tools without installing or replacing them.
mlpl-path:
    ./scripts/select-mlpl

mlplunit-path:
    ./scripts/select-mlplunit

mlpl-build-path:
    ./scripts/select-mlpl-build

# Verify script process behavior and native numeric compiler parity.
capabilities:
    ./scripts/check-process-io
    ./scripts/check-write-stdout
    ./scripts/check-compiler

# Regenerate and validate tiny deterministic byte fixtures.
generate-byte-fixtures:
    ./scripts/generate-byte-fixtures --write

generate-wav-fixtures:
    ./scripts/generate-wav-fixtures --write

generate-mp3-fixtures:
    ./scripts/generate-mp3-fixtures --write

generate-ogg-fixtures:
    ./scripts/generate-ogg-fixtures --write

# Run the readable byte-processing applications.
hexdump:
    ./scripts/run-byte-demo hexdump

histogram:
    ./scripts/run-byte-demo histogram

# Count bytes through bounded file ranges without whole-file materialization.
bounded-histogram:
    ./scripts/run-byte-demo range_histogram

# Copy 17 bytes in 7+7+3 bounded append chunks with a SHA-256 oracle.
bounded-copy:
    ./scripts/run-copy-demo

byte-demos:
    ./scripts/check-byte-demos

# Decode a golden MPEG audio header through a data-described field layout.
binary-fields:
    ./scripts/run-binary-demo mpeg_header

# Scan structural MPEG frames with VBR and damaged-gap contrasts.
mp3-scan:
    ./scripts/run-mp3-demo scan

# Inspect bounded ID3 metadata, audio bounds, and malformed-tag behavior.
id3-inspect:
    ./scripts/run-mp3-demo id3

# Strip ID3 and extract only accepted MPEG frames through bounded append writes.
mp3-bounded-output:
    ./scripts/run-mp3-demo bounded_output

# Opt-in pinned ffprobe comparison against the decodable tone fixture.
mp3-oracle:
    ./scripts/run-mp3-oracle

# Inspect Ogg page/lacing descriptors without reading payloads.
ogg-pages:
    ./scripts/run-ogg-demo pages

# Reconstruct bounded packet boundaries across Ogg pages.
ogg-packets:
    ./scripts/run-ogg-demo packets

# Verify Ogg checksums visibly in MLPL and contrast corruption.
ogg-crc:
    ./scripts/run-ogg-demo crc

# Copy one Ogg page and visibly rewrite its sequence with a recomputed CRC.
ogg-bounded-output:
    ./scripts/run-ogg-demo bounded_output

# Emit exact raw bytes to stdout; narration remains on stderr.
stdout-bytes:
    ./scripts/run-stdout-demo raw

# Emit a complete canonical WAV to stdout; narration remains on stderr.
stdout-wav:
    ./scripts/run-stdout-demo wav

# Emit one checksum-verified Ogg page to stdout; narration remains on stderr.
stdout-ogg:
    ./scripts/run-stdout-demo ogg

# Opt-in pinned ffprobe comparison against the decodable Ogg/Opus tone.
ogg-oracle:
    ./scripts/run-ogg-oracle

# Inspect and canonically copy a tiny PCM WAV file.
wav-inspect-copy:
    ./scripts/run-wav-demo

# Inspect WAV metadata through bounded reads without retaining sample payloads.
wav-range-inspect:
    ./scripts/run-wav-demo range_inspect

# Canonically copy and visibly invert PCM samples through bounded append writes.
wav-bounded-output:
    ./scripts/run-wav-demo bounded_output

# Opt-in: generate sparse inputs and enforce bounded-read peak-RSS ceilings.
sparse-memory-evidence:
    ./scripts/run-sparse-memory-evidence

# Opt-in: copy 1 MiB and 64 MiB outputs and enforce peak-RSS ceilings.
bounded-output-memory-evidence:
    ./scripts/run-bounded-output-memory-evidence

# Opt-in: redirect 1 MiB and 64 MiB binary stdout and enforce peak-RSS ceilings.
stdout-memory-evidence:
    ./scripts/run-stdout-memory-evidence

# Identify and structurally inspect WAV, Ogg, MP3/ID3, or unknown input.
media-inspect path="fixtures/mp3/synthetic-vbr-id3.mp3":
    ./scripts/run-media-inspector "{{path}}"

# Explain healthy, warning, rejected, and unknown structural outcomes.
media-doctor:
    ./scripts/run-media-doctor

# Create a canonical WAV copy or unsigned-8-bit inversion artifact.
wav-transform source="fixtures/wav/minimal-mono8.wav" destination=".wav-tool-output.wav" mode="invert_u8" chunk_size="2":
    ./scripts/run-wav-transform "{{source}}" "{{destination}}" "{{mode}}" "{{chunk_size}}"

# Demonstrate deterministic Unix-ms sorting and UTC formatting over metadata-shaped values.
file-date-index:
    ./scripts/run-date-index-demo

# Count bytes, LF lines, logical lines, and ASCII-delimited words with bounded reads.
wc-like:
    ./scripts/run-wc-demo

# Search literal bytes by line with bounded reads, retained line state, and results.
grep-like:
    ./scripts/run-grep-demo

# Walk confined regular files and total logical bytes with explicit budgets.
du-like:
    ./scripts/run-du-demo

# Compile the whole-stdin wc-style filter to target/demo-bin/mlpl-wc.
compiled-wc:
    ./scripts/build-wc-stdin

# Run the complete pre-commit gate.
check:
    ./scripts/check

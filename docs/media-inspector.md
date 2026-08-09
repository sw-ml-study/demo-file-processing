# Unified media inspector

`just media-inspect [path]` runs an argument-driven interpreter application
that identifies WAV, Ogg, MP3/ID3, or unknown input from bounded leading bytes
and dispatches to the repository's existing MLPL parsers.

The result has one stable record shape across formats. Its common fields report
path, detected format, evidence, file size, and chunk budget. WAV populates PCM
geometry and unknown-chunk counts; Ogg populates first-page serial, sequence,
lacing/body facts, and CRC validity; MP3 populates selected ID3 text, Layer III
frame/rate statistics, and duration. Fields that do not apply retain documented
zero or empty-string defaults rather than changing the record shape.

The demo is deliberately self-describing. It names the input and signature
evidence, separates MLPL parsing/validation work from native range-read effects,
explains the format-specific output, and states that it is an interpreter
application rather than decoded audio or a standalone compiled executable.

## Boundedness and ownership

Detection reads at most twelve leading bytes. Format inspection uses the
caller's fixed range-read chunk size and existing explicit limits:

- at most 1,024 WAV chunk descriptors;
- at most 1 MiB for the first Ogg page and its CRC traversal;
- at most 1 MiB of ID3, 4,096 ID3/MPEG frames, and 65,536 recognized text
  bytes.

MLPL owns dispatch, RIFF/Ogg/ID3/MPEG structure, endian and bit operations,
extent checks, aggregation, and CRC. The native runtime owns file metadata and
bounded offset/length reads. No native media parser, decoder, encoder, ffmpeg,
or ffprobe participates.

The application retains bounded descriptors and per-window bytes, not audio or
packet payloads. This composes previously measured primitives; it does not add
a new peak-RSS claim beyond their accepted reports.

## Coverage

Native mlplunit tests cover representative WAV/Ogg/MP3 files, chunk invariance,
empty and unknown input, truncated ID3/Ogg, checksum-damaged Ogg, unsupported ID3 flags,
missing and sandbox-escaping paths, and invalid chunk budgets. The shell oracle
pins meaningful narrated outputs for every dispatch branch.

```sh
just media-inspect
just media-inspect fixtures/wav/odd-unknown-mono8.wav
just media-inspect fixtures/ogg/structural-cross-page.ogg
just media-inspect fixtures/bytes/boundary-17.bin
just tests tests/apps/test_media_inspector.mlpl
```

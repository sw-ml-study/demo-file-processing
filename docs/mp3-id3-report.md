# MP3/ID3 read-only acceptance report

## Decision

The `mp3-id3-inspection` saga is accepted for bounded, seekable, read-only
inspection. MLPL owns MPEG header semantics, frame synchronization and
statistics, ID3v2 structure/text policy, and descriptor construction. The
native runtime supplies only file metadata, bounded byte reads, generic bit
operations, and UTF-8 byte decoding. No native MP3/ID3 parser or codec is used
by the default path.

This accepts inspection, not audio decoding, metadata rewriting, frame
extraction, streaming input, bounded output, or a compiled standalone
application.

## Executable evidence

At acceptance, `just check` passes:

- 56 registered native mlplunit tests across 17 suites;
- 16 catalog entries: 13 runnable and three explicitly constrained;
- six catalog entries with chunk-bounded read-side behavior;
- generated fixture size and SHA-256 checks;
- stable narrated MPEG-header, MPEG-scan, ID3, byte, and WAV demo landmarks;
- numeric/compiler parity values `28` and `72`, with unsupported application
  lowering still checked explicitly.

MP3 evidence covers MPEG-1, MPEG-2, and de-facto MPEG-2.5 Layer III headers;
reserved/free selectors; CBR and VBR; false synchronization; damaged-gap
reacquisition; synchronized truncation; byte/frame budgets; ID3v2.3/v2.4,
extended headers, v2.4 footers, padding, selected text, unknown frames,
malformed extents/flags/encodings, and tag/frame/text budgets. Required results
agree at chunk sizes 1, 7, 64, and 65,536.

The opt-in `just mp3-oracle` is checksum- and ffprobe-8.1.2-pinned. MLPL and
ffprobe agree on the decodable fixture title and 44,100 Hz rate. MLPL counts
twelve structural frames, including Xing/LAME information; ffprobe reports
eleven decoded packets and a gapless presentation duration of 0.250000 seconds.
Those are intentionally different quantities.

## Stabilized read-only contracts

```text
parse_mpeg_layer3_header(bytes[4]) -> Result<header, error>

scan_mpeg_layer3(
  path, chunk_size, start_offset, end_offset, max_scan_bytes, max_frames
) -> Result<statistics, error>

inspect_id3v2(
  path, chunk_size, max_tag_bytes, max_frames, max_text_bytes
) -> Result<metadata_and_audio_descriptor, error>
```

The scanner returns accepted offsets, frame/sample/byte totals, structural
duration, resynchronization and skipped-byte counts, min/max/average bitrate
and frame length, bitrate changes, a fixed 15-bin bitrate-index histogram, and
a fixed four-bin channel-mode histogram.

The ID3 result returns tag extent, selected text/counts, padding and extended-
header/footer facts, plus `{audio_offset, audio_bytes}`. A no-tag file describes
the entire file as audio. The later [bounded MP3 output](bounded-mp3-output.md)
copies that range or rescans and appends accepted frames incrementally without
returning an unbounded frame list.

## Complexity and allocation

- MPEG header parsing is O(1) over four bytes and thirteen fixed fields.
- Frame scanning is O(n) header candidates in the worst case and O(f) accepted
  frames. Each candidate reads four bytes; accepted payloads are skipped by
  decoded offset. State is scalars plus fixed 15- and four-cell histograms. A
  hostile unsynchronized range can cause one bounded read per byte and is
  capped by `max_scan_bytes`.
- ID3 walking is O(f + p + t): frame headers, padding bytes, and recognized
  text bytes. Unknown payloads are skipped by offset. Header windows are at
  most ten bytes and padding windows at most 64 bytes. Retained and transient
  text allocation is capped by `max_text_bytes`; `concat` in a multi-read text
  window can copy intermediate arrays.

These are structural bounded-memory arguments, not new peak-RSS measurements.
The accepted sparse histogram/WAV evidence covers the shared range runtime, but
MP3/ID3 RSS has not been measured on growing files. No measured-memory claim is
made here.

## Supported and unsupported formats

Supported MPEG input is Layer III with MPEG-1, MPEG-2, or labeled de-facto
MPEG-2.5 tables. Free bitrate is rejected. A scan fixes version/layer/sample
rate but permits bitrate and channel-mode changes. It does not decode payloads,
interpret Xing/VBRI/LAME content, calculate gapless presentation time, or
validate compressed audio data.

Supported tags are ID3v2.3 and v2.4 at byte zero, with accepted extended-header
layouts, padding, and mirrored v2.4 footer. Selected UTF-8 and ASCII-compatible
encoding-0 text is returned. ID3v2.2, UTF-16, non-ASCII ISO-8859-1 conversion,
unsynchronization, experimental tags, compression, encryption, grouping, and
data-length-indicated frames remain explicit errors. ID3v1 tail discovery is
not implemented.

## Blockers and next work

There is no blocker to the next highest-value saga: bounded read-only Ogg page,
lacing, packet-continuation, and CRC inspection can reuse the range contracts.
Arbitrary 64-bit granule positions must use two exact 32-bit words.

Sandboxed file-path output is now implemented through `append_bytes`; binary
stdout/non-seekable sinks remain unavailable. Standalone applications remain blocked on compiler lowering/runtime
parity for byte I/O, bits, arguments, diagnostics, and exit status. Codec work
remains later and must use explicit chunk-oriented extension boundaries.

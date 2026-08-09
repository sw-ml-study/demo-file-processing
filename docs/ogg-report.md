# Ogg read-only acceptance report

## Decision

The `ogg-container-inspection` saga is accepted for bounded, seekable,
single-logical-stream, read-only inspection. MLPL owns page/lacing parsing,
cross-page packet state, split-word granule representation, CRC calculation,
integrity decisions, budgets, and descriptors. The native runtime supplies only
file metadata, bounded reads, endian/bit primitives, and ordinary arrays.

This accepts Ogg container structure and integrity, not codec parsing or
decoding, multiplexed-stream reconstruction, page rewriting, output, streaming
stdin, or standalone compilation.

## Executable evidence

At acceptance, `just check` passes:

- 68 registered native mlplunit tests across 21 suites;
- 19 catalog entries: 16 runnable and three constrained;
- nine chunk-bounded catalog entries;
- generated fixture sizes and SHA-256 values;
- stable narrated page, packet, CRC, MP3, byte, and WAV demo landmarks;
- numeric/compiler parity values `28` and `72`, with unsupported application
  lowering still checked.

Ogg tests cover capture/version/reserved flags; BOS/continued/EOS; empty and
255-byte lacing; exact low/high granule words and the unset sentinel; body/page
extents; cross-page, ordinary, and zero-length packets; serial and sequence
faults; truncation; every page/segment/body/stream/packet/CRC budget; independent
CRC vectors; stored-checksum matching and corruption; and chunk sizes 1, 7, 64,
and 65,536.

The opt-in `just ogg-oracle` pins the fixture checksum and ffprobe 8.1.2. MLPL
reports three checksum-valid pages and fifteen structural packets. ffprobe
reports thirteen decoded Opus packets because `OpusHead` and `OpusTags` are
container packets, plus mono 48 kHz and 0.256500 seconds. The installed FFmpeg
lacks `libvorbis`, so this evidence is explicitly Ogg/Opus; Ogg parsing remains
codec-independent.

## Stabilized read-only contracts

```text
open_ogg_page(
  path, chunk_size, offset, max_page_bytes, max_segments, max_body_bytes
) -> Result<page_descriptor, error>

inspect_ogg_packets(
  path, chunk_size, start_offset, end_offset,
  max_stream_bytes, max_pages, max_page_bytes, max_segments,
  max_page_body_bytes, max_packets, max_packet_bytes
) -> Result<packet_statistics, error>

inspect_ogg_page_crc(...) -> Result<checksum_evidence, error>
verify_ogg_page_crc(...)  -> Result<checksum_evidence, checksum_error>
```

A page descriptor contains exact page/header/body/next offsets and lengths,
lacing, packet-ending count, flags, serial, sequence, stored checksum, and exact
`granule_low`/`granule_high` words. It is also the future rewrite descriptor:
an incremental sink can copy `[offset, page_bytes]`, omit it, or rebuild the
header/body and recompute CRC. No output is performed now.

Packet inspection returns fixed-size aggregate statistics rather than an
unbounded packet list. A future codec or writer can rescan validated page body
ranges and consume lacing incrementally.

## Complexity and allocation

- Page parsing is O(segments), materializing 27 fixed header bytes and at most
  the budgeted lacing table; page bodies remain descriptors.
- Packet inspection is O(pages + segments), retaining fixed aggregate state
  plus one page's bounded lacing table. It may perform multiple bounded reads
  per page according to the configured chunk size.
- CRC is O(8 × page bytes), retaining scalar CRC state plus one caller-capped
  chunk. Stored bytes 22–25 are logically zeroed without rewriting input.

These are structural bounded-memory claims under explicit budgets, not new
peak-RSS measurements. Ogg-specific RSS has not been measured on growing files,
and no measured-memory claim is made.

## Supported and unsupported input

Supported pages use Ogg stream-structure version zero and exact u32 fields.
Granule positions remain split words; no inexact f64 combination is exposed.
One packet scan accepts one serial with consecutive sequence values, one BOS,
one final EOS, and continuation flags matching lacing state.

Multiplexed serials, chained logical streams in one scan range, resynchronizing
past damaged capture patterns, codec header semantics, granule arithmetic,
payload decoding, and non-seekable sources are outside this contract. Callers
may inspect known separate logical-stream ranges independently. CRC mismatch is
visible independently from structural parsing.

## Blockers and next work

All planned downstream-only read-only sagas are accepted. The next planned saga
is incremental binary output, but it is blocked pending explicit authorization
for a generic upstream sink with partial-write, flush, close, cleanup, sandbox,
and bounded-memory semantics. That is the smallest action needed to unlock Ogg
page copy/rewrite, ID3 stripping, MPEG extraction, and bounded WAV output.

Standalone file applications remain blocked on compiler/runtime parity for
byte I/O, bits, arguments, diagnostics, and exit status. Audio codec and
MP3-to-Ogg work require separately authorized chunk-oriented decoder/encoder
extension boundaries as well as the sink. No feature-specific Ogg runtime
builtin is requested.

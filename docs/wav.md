# PCM WAV inspection and canonical copy

The WAV slice parses RIFF chunks, validates a deliberately narrow PCM subset,
and writes a normalized copy. MLPL owns RIFF traversal, little-endian field
decoding, format decisions, semantic validation, padding, and serialization.
The generic runtime only supplies whole-file byte reads/writes.

The implementation follows the RIFF/WAVE structure described by the
[EBU Broadcast Wave Format specification](https://tech.ebu.ch/docs/tech/tech3285.pdf),
which builds on Microsoft WAVE: a `RIFF` form with `WAVE` type, size-delimited
chunks, mandatory `fmt ` and waveform-data chunks, and word-aligned chunk data.
That specification is normative; repository fixtures are merely golden cases.

## Run

```sh
just generate-wav-fixtures
just wav-inspect-copy
just wav-range-inspect
just tests tests/wav
just check
```

The demo reads a three-frame mono 8-bit fixture, reports its format, encodes a
canonical copy, writes and rereads it, and requires byte identity before
removing the temporary output.

## Supported semantic subset

- RIFF/WAVE with a `fmt ` chunk of at least 16 bytes and one `data` chunk;
- PCM format code 1;
- one or two channels;
- 8-bit or 16-bit samples;
- positive sample rate;
- byte rate and block alignment consistent with channels/sample width;
- data length containing a whole number of frames;
- unknown chunks skipped using their declared size and odd-byte padding.

Duplicate `fmt ` or `data` chunks, missing required chunks, bad signatures,
inconsistent RIFF lengths, truncated headers/payloads/padding, size overflow,
unsupported encoding/channel/width values, inconsistent derived rates, and
partial frames return `Err`.

`parse_wav(bytes, max_bytes, max_chunks)` rejects an already-materialized input
larger than `max_bytes` and caps chunk traversal. The byte budget protects
parser work but does not undo the allocation performed by whole-file
`read_bytes`; callers needing a true allocation bound must use range reads in a
later streaming parser. All u16/u32 RIFF fields are exact under the existing
f64 integer boundary.

## Canonicalization and round trips

`encode_wav` emits exactly:

1. `RIFF` + exact body size + `WAVE`;
2. a 16-byte PCM `fmt ` chunk;
3. one `data` chunk;
4. a zero pad byte when the data length is odd.

Canonical empty and minimal fixtures satisfy
`encode(parse(bytes)) == bytes`. Unknown chunks are intentionally not retained;
their files satisfy semantic round trip instead, and canonical output reports
zero unknown chunks. This distinction prevents a normalized writer from being
misrepresented as a byte-preserving arbitrary-WAV editor.

## Fixtures and tests

sw-MLPL generates three tiny committed fixtures: empty mono PCM, three-frame
mono PCM with odd data padding, and a file with an odd-sized padded `JUNK`
chunk before data. Native mlplunit tests cover those fixtures plus malformed
lengths, truncated padding, huge declared payloads, signatures, missing chunks,
unsupported variants, inconsistent rates/alignment, partial frames, and byte/
chunk budgets.

For read-only use, the [bounded WAV inspector](wav-range-inspection.md) reads
only small headers, skips sample and unknown payloads by validated offsets, and
matches this parser's metadata without retaining the `data` array. It makes no
copy or output claim.

Parsing is logically O(file bytes + chunks). The current immutable slice and
recursive concatenation helpers can copy O(n²) bytes, and the parser retains a
second f64-backed copy of the data payload. Encoding likewise builds immutable
intermediates and then `write_bytes` copies/converts to physical bytes. This is
a small-file correctness demonstration—not packed storage, bounded streaming,
or a throughput claim.

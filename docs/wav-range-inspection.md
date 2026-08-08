# Bounded WAV metadata inspection

`u:inspect_wav_ranges(path, chunk_size, max_chunks)` inspects RIFF/WAVE and the
supported PCM metadata without a whole-file read and without retaining sample
payload bytes. It reads the 12-byte RIFF header, every 8-byte chunk header, and
the first 16 bytes of `fmt ` through the shared bounded range APIs. Validated
data and unknown payloads are skipped by offset and length.

```sh
just wav-range-inspect
just tests tests/wav/test_wav_range.mlpl
```

The result reports PCM fields, data offset/length, frame count, duration, and
chunk counts. It deliberately has no `data` field and performs no copy, write,
or transformation.

## Boundary and parity evidence

The generic range-window helper assembles only explicitly budgeted small
windows, with each native read capped by the reader chunk budget. Tests run the
odd-padded fixture with budgets 1 through 16, exercising every internal split
position of the 16-byte `fmt ` prefix and therefore every split in the shorter
RIFF and chunk headers. Budgets 64 and 65,536 exercise clamping.

Bounded results match the existing whole-buffer semantic parser for empty,
minimal, and odd-sized padded-unknown-chunk fixtures. Tests also cover bad
signatures, truncated headers/payload declarations, unsupported PCM encoding,
and chunk budgets. Odd chunk padding advances the next header and data offset;
the inspector validates that the declared padded extent is inside the file.

## Ownership, complexity, and limits

MLPL owns window assembly, RIFF/chunk traversal, endian decoding, padding,
budgets, PCM validation, and derived metadata. The native runtime owns metadata
and bounded reads. The whole-buffer parser appears only as a test oracle.

For `k` chunks, scanning is O(k) plus at most 16 bytes of format decoding; data
payload size does not contribute to bytes read. Live MLPL state is one fixed
metadata record plus header/window arrays of at most 16 f64 cells. Immutable
`concat` makes assembly of one header quadratic in its length, but that length
is capped at 16. Peak resident memory is structurally independent of sample
payload length but remains unclaimed until the sparse-file RSS step measures
runtime and allocator behavior.

The size is a metadata snapshot. Concurrent truncation becomes a short-read or
truncation error; growth beyond the declared RIFF/file size is rejected or
ignored according to the validated snapshot. The inspector supports the same
narrow PCM subset as the whole-buffer parser and does not preserve unknown
payloads because it never reads them.

# Bounded MP3 output

Two output paths turn the accepted ID3 and MPEG read contracts into sandboxed
files without retaining the complete result.

`strip_id3v2` validates the tag and copies exactly `{audio_offset, audio_bytes}`
to a new destination. A no-tag input therefore copies from byte zero. The
output is byte-for-byte identical to the described range; the mlplunit oracle
compares it in independent 64-byte windows rather than allocating both full
artifacts.

`extract_mpeg_frames` first validates the requested range with
`scan_mpeg_layer3`. Only after that pass succeeds does it create the output. A
second bounded-state pass applies the same compatibility and two-header
acquisition rules, appending every accepted frame range in caller-sized chunks.
It retains no frame list. Prefix junk, false synchronization, damaged gaps, and
trailing unaccepted bytes are omitted. Final frame and byte counts must equal
the first-pass summary.

Both APIs require a new destination, enforce explicit scan/output budgets,
verify every append count, and use the caller-selected keep/remove policy for a
partial file after a later failure. Allocation is fixed descriptor/scanner
state plus O(`chunk_size`) byte vectors. MPEG payloads are preserved but not
decoded, so structural acceptance is not a claim that synthetic fixtures
contain playable compressed audio.

Run `just mp3-bounded-output` for two narrated outputs: a 1,356-byte ID3-free
VBR stream and a 1,668-byte four-frame stream with a damaged two-byte source gap
removed. The artifacts currently target files; the later
[`write_stdout`](write-stdout.md) sink enables interpreter binary stdout. Its
development compiler lowering still has a textual wrapper trailer, and file
I/O lowering remains unavailable, so pristine standalone output is blocked.

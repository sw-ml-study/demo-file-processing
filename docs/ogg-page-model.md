# Bounded Ogg page model

`src/ogg/page.mlpl` parses one page at an exact seekable-file offset through the
shared range/window contract. The fixed 27-byte header and at most 255 lacing
bytes are materialized; the page body is represented only by validated offset
and length. Explicit total-page, segment-count, and body-byte budgets are
checked before returning the descriptor.

The parser validates `OggS`, stream-structure version zero, reserved header-type
bits, lacing extent, body sum, and containment in the file snapshot. It exposes
continuation, beginning/end-of-stream flags, stream serial, page sequence,
stored checksum, segment table, packet-ending count, body range, and next-page
offset. Checksum calculation belongs to a later dedicated step.

Ogg's 64-bit granule position is returned as exact `granule_low` and
`granule_high` 32-bit words. The all-ones unset sentinel is reported separately.
The words are not combined into one f64, which would lose exactness above 2^53.

Parsing is O(segments) time and allocation plus fixed header state; body bytes
are never read. Native mlplunit vectors cover lacing values 0/255, empty pages,
split-word values, the unset sentinel, malformed signatures/versions/flags and
extents, all budgets, and identical results at chunks 1, 7, 64, and 65,536.

The [packet reconstruction layer](ogg-packet-reconstruction.md) composes these
descriptors across consecutive pages while keeping payload bytes out of memory.
The separate [visible CRC verifier](ogg-crc.md) traverses page bytes only when a
caller requests integrity evidence.

Committed [structural, malformed, and decodable fixtures](ogg-fixtures-oracle.md)
drive the narrated page, packet, CRC, and opt-in oracle demonstrations.

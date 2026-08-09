# Bounded Ogg page output

The Ogg output slice turns accepted page descriptors and visible CRC evidence
into sandboxed files without retaining a complete page.

`copy_ogg_page` first requires the source page's stored checksum to match the
MLPL polynomial calculation. It then copies exactly `[offset, page_bytes]`
through the shared bounded range writer. Tests compare the result with the
source in independent 64-byte windows and verify the copied CRC.

`rewrite_ogg_page_sequence` validates the original page, encodes a new exact
u32 sequence, and makes two bounded passes. The first computes CRC while
virtually replacing relative bytes 18–21 and zeroing bytes 22–25. The second
appends source chunks while replacing sequence and checksum bytes wherever a
chunk intersects those fields. Lacing and body bytes are never rebuilt or
retained. The rewritten page must have the same length and pass the independent
page parser and CRC verifier.

Both APIs require a new destination, enforce page/CRC/output budgets, verify
append counts, and apply the caller's keep/remove policy after a later failure.
State is a page descriptor, four-byte encodings, scalar CRC, and
O(`chunk_size`) byte vectors.

Run `just ogg-bounded-output` for a byte-identical 283-byte copy and a second
283-byte page whose sequence changes from 10 to 42 with a recomputed checksum.
The rewrite is intentionally page-local: callers rewriting a logical stream
must choose consistent consecutive sequences themselves. Binary stdout and
standalone compiled I/O remain unavailable.

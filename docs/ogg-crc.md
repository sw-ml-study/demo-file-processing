# Visible Ogg CRC verification

`src/ogg/crc.mlpl` implements the Ogg non-reflected CRC-32 polynomial
`0x04C11DB7` directly in MLPL with initial value zero and no final xor. Page
calculation logically substitutes zero for fixed-header bytes 22 through 25,
as required when calculating the checksum stored in that field.

`inspect_ogg_page_crc` returns stored and computed values plus a validity flag;
`verify_ogg_page_crc` turns mismatch into an explicit checksum error. Structural
page parsing remains independently usable, so callers do not pay to traverse a
body unless they request integrity verification.

Page verification reads through a caller-capped `crc_chunk_size` and rejects a
page beyond `max_crc_bytes` before traversal. It retains one chunk plus scalar
CRC state and performs O(page bytes × 8) bit steps. The implementation uses
generic fixed-width MLPL bit operations; no native Ogg parser or checksum
implementation participates.

Golden vectors independently calculated from the polynomial are empty = 0,
`OggS` = `0x5FB0A94F`, and `123456789` = `0x89A1897F`. Native mlplunit also
checks a stored page CRC at chunk sizes 1, 7, 64, and 65,536, body corruption,
mismatch evidence, required-verification error behavior, invalid bytes, and CRC
budgets.

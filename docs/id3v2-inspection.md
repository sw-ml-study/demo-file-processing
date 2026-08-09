# Bounded ID3v2 inspection

`src/id3/inspect.mlpl` recognizes an ID3 tag at byte zero and returns selected
metadata plus a validated `{audio_offset, audio_bytes}` descriptor. It performs
no stripping, copying, or output writes. A file without an ID3 signature returns
a successful descriptor whose audio range is the entire file.

The implementation follows the published ID3v2.3 and ID3v2.4 structures:
ten-byte tag and frame headers, 28-bit synchsafe tag sizes, big-endian v2.3
frame sizes, synchsafe v2.4 frame sizes, padding, version-specific extended
header lengths, and the optional mirrored v2.4 footer. Header, frame, payload,
and footer extents must remain inside the declared tag and file snapshot.

## Budgets and bounded reads

`inspect_id3v2(path, chunk_size, max_tag_bytes, max_frames, max_text_bytes)`
rejects a declared tag beyond its byte budget before walking frames. It also
caps accepted frame count and cumulative bytes of recognized text payloads.
Frame headers use ten-byte windows, padding validation uses at most 64 bytes,
and unknown payloads are skipped by validated offset. Only recognized text is
materialized, under `max_text_bytes`; the whole tag and audio payload are never
retained.

The fixed result exposes tag version/flags/extent, extended-header/footer and
padding facts, frame/text/unknown counts, selected title (`TIT2`), artist
(`TPE1`), album (`TALB`), track (`TRCK`), and year/date (`TYER`/`TDRC`) values,
and the audio range for later read-only MPEG scanning or future bounded output.

## Deliberate supported subset

Text encoding byte 3 is decoded as UTF-8. Encoding byte 0 is accepted only when
all content bytes are ASCII, which is simultaneously valid UTF-8 and
ISO-8859-1. UTF-16 and non-ASCII ISO-8859-1 return explicit errors because the
current runtime does not expose a codec suitable for an honest conversion.
Terminal NUL padding is removed; embedded NULs are rejected.

Tag-level unsynchronization and experimental tags are rejected. Frame
compression, encryption, grouping, unsynchronization, and data-length indicators
are also rejected rather than skipped ambiguously. Free-form unknown frames with
ordinary flags are counted and skipped without reading their payloads.

Native mlplunit vectors cover v2.3/v2.4, both extended-header layouts, a v2.4
footer, padding, absent tags, malformed sizes/flags/text, truncation, all three
budgets, and identical results at chunk sizes 1, 7, and 65,536. Tiny committed
fixtures and external-oracle comparison remain assigned to the next saga step.

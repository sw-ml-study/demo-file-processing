# Bounded MPEG Layer III frame scanning

`src/mp3/scanner.mlpl` scans an explicitly bounded file range using the shared
range reader and semantic MPEG header parser. It reads four-byte header windows,
advances over accepted frame payloads by decoded length, and retains only
fixed-size aggregate state. It does not decode or retain compressed payloads.

The public operation is
`scan_mpeg_layer3(path, chunk_size, start_offset, end_offset, max_scan_bytes,
max_frames)`. Both work budgets are positive exact integers. The range must fit
`max_scan_bytes`; accepting a frame beyond `max_frames` is an error. Offsets
must be ordered and contained in the file-size snapshot.

## Synchronization policy

An unsynchronized candidate is accepted only when its semantic header is valid,
its decoded frame extent is contained, and either a compatible header exists at
the decoded next-frame offset or the frame ends exactly at the scan boundary.
Compatibility fixes MPEG version, Layer III, and sample rate while permitting
bitrate and channel-mode changes. This two-header acquisition rule rejects an
isolated sync-shaped sequence.

Once synchronized, decoded frame lengths determine the next header location.
Invalid bytes lose synchronization; the scanner advances one byte at a time and
applies acquisition again. A valid synchronized header whose frame extends
beyond the range is reported as truncation.

Results include frame count, audio offsets, skipped bytes, resynchronizations,
total frame bytes and samples, duration, a fixed fifteen-bin bitrate-index
distribution, a fixed four-bin channel-mode distribution, min/max/average frame
length, and constant/variable bitrate statistics. mlplunit covers isolated false synchronization, reacquisition after
damage, synchronized truncation, both budgets, and identical results with chunk
sizes 1, 7, 64, and 65,536.

## Boundary and limitation

Traversal is structurally bounded: each input window is four bytes and the
aggregate state has fixed size independent of file length. This step does not
claim measured peak-memory evidence. Free-bitrate Layer III remains unsupported
because one header cannot determine frame length. The separate
[ID3v2 inspector](id3v2-inspection.md) now supplies a validated audio offset and
length suitable for this scanner. Committed [fixtures and pinned oracle
evidence](mp3-fixtures-oracle.md) demonstrate VBR, damaged-gap recovery, and the
difference between a structural Xing frame and decoded audio packets.

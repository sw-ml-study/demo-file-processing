# MP3/ID3 fixtures and pinned oracle

Four committed fixtures keep structural, malformed, and independently decodable
evidence separate:

| Fixture | Bytes | Purpose |
| --- | ---: | --- |
| `synthetic-vbr-id3.mp3` | 1,432 | ID3v2.3 metadata followed by joint-stereo 128/160 and mono 128 kbit/s structural frames |
| `resync-gap.mp3` | 1,670 | four structural 128 kbit/s frames separated by a deliberate two-byte damaged gap |
| `malformed-truncated-id3.mp3` | 14 | tag declares 127 body bytes that do not exist |
| `tone-vbr-id3.mp3` | 1,976 | decodable mono 440 Hz quarter-second tone with a v2.4 title for the opt-in oracle |

The first three are regenerated entirely in MLPL by `just
generate-mp3-fixtures`. Structural frame payloads are deliberately synthetic
and are not represented as playable audio. The tone was generated locally with
FFmpeg 8.1.2 from its `sine` source and contains no third-party recording:

```sh
ffmpeg -f lavfi -i 'sine=frequency=440:sample_rate=44100:duration=0.25' \
  -map_metadata -1 -metadata title='Bounded 440 Hz tone' \
  -codec:a libmp3lame -q:a 5 -id3v2_version 4 -write_id3v1 0 tone-vbr-id3.mp3
```

The fixture check pins every size and SHA-256. The decodable tone checksum is
`8edfa02de35922fbec07a51d6db07ddfe61b88ea9d0d54611b510ac32492a3d3`.

## Opt-in oracle

`just mp3-oracle` requires exactly ffprobe 8.1.2 and refuses other versions so
the evidence cannot drift silently. It first verifies the fixture checksum,
then compares the independent bounded MLPL inspection with ffprobe.

Both report title `Bounded 440 Hz tone` and 44,100 Hz. MLPL reports twelve
structurally valid MPEG frames; ffprobe reports eleven decoded packets because
the leading Xing/LAME information frame is structural metadata rather than an
audio packet. ffprobe additionally interprets gapless timing and reports a
0.250000-second presentation duration. The distinction is narrated rather than
treating frame count and decoded-packet count as the same quantity.

ffprobe is never used by the default tests or demonstrations and performs none
of their parsing, resynchronization, or aggregation. Its only role is this named
opt-in validation boundary.

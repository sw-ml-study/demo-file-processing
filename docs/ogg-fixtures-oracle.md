# Ogg fixtures and pinned oracle

The Ogg evidence keeps structural teaching cases, malformed cases, and a
decodable codec-aware oracle separate:

| Fixture | Bytes | Purpose |
| --- | ---: | --- |
| `structural-cross-page.ogg` | 356 | three valid-CRC pages with a 265-byte spanning packet, ordinary packets, and a zero packet |
| `malformed-continuation.ogg` | 321 | checksum-valid pages whose second page omits the required continued flag |
| `malformed-crc.ogg` | 356 | structural stream with one first-page body byte changed after checksum encoding |
| `tone-opus.ogg` | 2,324 | decodable mono 440 Hz Ogg/Opus tone with title metadata for the opt-in oracle |

The first three are regenerated entirely in MLPL by `just
generate-ogg-fixtures`, including their stored CRC values. All fixture sizes
and SHA-256 values are pinned. The tone contains no third-party recording; it
was generated locally from FFmpeg 8.1.2's sine source:

```sh
ffmpeg -f lavfi -i 'sine=frequency=440:sample_rate=48000:duration=0.25' \
  -map_metadata -1 -metadata title='Bounded Ogg tone' \
  -codec:a libopus -b:a 48k tone-opus.ogg
```

The installed FFmpeg lacks `libvorbis`, so the oracle is explicitly Ogg/Opus,
not Ogg/Vorbis. This does not block codec-independent Ogg page, lacing, packet,
or CRC validation. Vorbis encoding remains later codec-extension work.

## Pinned oracle

`just ogg-oracle` requires exactly ffprobe 8.1.2 and verifies SHA-256
`82b696a43679702d6aa581707857d466050eb5ac74df4d1db0153e305e69c03c`.
MLPL reports three checksum-valid pages and fifteen structural packets. ffprobe
reports Ogg/Opus, mono 48 kHz, title `Bounded Ogg tone`, thirteen decoded audio
packets, and 0.256500 seconds.

The two extra MLPL packet boundaries are `OpusHead` and `OpusTags`. They are
container packets but not decoded audio packets. ffprobe is opt-in validation
only and performs none of the default MLPL page, continuation, or CRC work.

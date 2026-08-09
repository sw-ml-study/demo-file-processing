# Structural media doctor

`just media-doctor` demonstrates five materially different outcomes from the
same bounded validation stack: healthy MP3, valid WAV with a normalization
caveat, damaged MP3 with recoverable confirmed frames, rejected Ogg packet
continuation, and unknown bytes.

The application returns a stable diagnosis containing format, status, reason,
safe next action, file size, issue count, recovered frame/packet count, and
resynchronizations. Its policy is deliberately conservative:

- **healthy** means the inspected container/frame structure is internally
  consistent under the configured budgets, not that a codec can decode it;
- **warning** permits only the named bounded operation and explains possible
  information loss or excluded damage;
- **rejected** converts a parser/runtime error into a diagnosis and recommends
  no transformation; and
- **unknown** refuses to guess from a filename extension.

MLPL owns all health policy, parser composition, CRC/packet/frame reasoning,
and recommendations. The native runtime provides file metadata and bounded
range reads. No codec, repair library, ffmpeg, or ffprobe participates.

The doctor composes previously accepted bounded-memory primitives and adds no
new peak-RSS claim. Native mlplunit tests cover healthy WAV/Ogg/MP3, WAV
ancillary-chunk warnings, MP3 gap recovery, Ogg continuation and CRC rejection,
unsupported ID3 flags, missing files, unknown bytes, and chunk invariance.

```sh
just media-doctor
just tests tests/apps/test_media_doctor.mlpl
```

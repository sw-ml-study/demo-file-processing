# Bounded WAV transforming application

`just wav-transform [source] [destination] [mode] [chunk-size]` creates a real
canonical PCM WAV through the interpreter's bounded file-path sink. Supported
modes are `copy` and `invert_u8`.

The application is intentionally safer than an overwrite-style utility:

- the destination must not exist;
- source RIFF extent and PCM geometry are validated before output;
- every bounded read and append count is checked;
- failures use the existing explicit partial-output cleanup policy;
- the completed artifact is boundedly reparsed and its geometry compared with
  the source; and
- at most eight source/output samples are retained for a visible mode oracle.

Copy mode preserves PCM samples while canonicalizing the RIFF layout, so
unknown ancillary chunks are intentionally removed and padding is regenerated.
`invert_u8` requires unsigned 8-bit PCM and maps every sample `x` to `255-x`.
It is a sample-domain transform, not decoding or re-encoding compressed audio.

Production payload state is O(chunk size), plus fixed metadata/header state.
The tiny mlplunit fixtures are also read completely as independent exact or
semantic test oracles; those test-only reads are not part of the application
algorithm. Existing sparse-output measurements support the underlying bounded
writer, so this composition adds no new peak-RSS claim.

The narrated demo explains arguments, ownership, artifact layout, write chunks,
sample previews, interpretation, cleanup, and the interpreter/compiler boundary.
Exact shell oracles use `cmp` for canonical copy and inspect output payload bytes
`[255, 128, 0]` for inversion.

```sh
just wav-transform
just wav-transform fixtures/wav/odd-unknown-mono8.wav .normalized.wav copy 7
just tests tests/apps/test_wav_transform.mlpl
```

Remove or choose a new destination before rerunning. This is an
argument-driven seekable-file interpreter application, not a standalone native
executable.

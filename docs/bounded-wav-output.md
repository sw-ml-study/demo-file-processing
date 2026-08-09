# Bounded WAV output

`bounded_wav_output` turns the accepted range-inspection descriptor into a new,
canonical PCM WAV without retaining the full sample payload. It writes a fixed
44-byte RIFF/fmt/data header, copies or transforms exact data ranges in caller-
bounded chunks, verifies every append count, and emits the required zero pad for
odd payload lengths.

The `copy` mode preserves PCM samples while normalizing away ancillary chunks.
For an already canonical input, the complete output is byte-identical. The
`invert_u8` mode supports unsigned 8-bit PCM and maps each sample `x` to
`255 - x`; the demonstration therefore changes `[0, 127, 255]` to
`[255, 128, 0]` without changing format, frames, rate, or duration.

The destination must not exist. `max_output_bytes` covers the full canonical
file—header, payload, and pad—and failures after creation follow the caller's
keep/remove partial-output choice. Source metadata is validated before output
creation. The library retains a fixed header plus O(`chunk_size`) input and
output vectors. Tests may read tiny complete outputs as independent byte and
semantic oracles; that readback is not part of the production algorithm.

Run `just wav-bounded-output` for the narrated result. Output remains limited to
sandboxed file paths. The later [`write_stdout`](write-stdout.md) sink enables a
separate interpreter stdout path; standalone compiler I/O lowering is not
available.

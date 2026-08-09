# Bounded incremental-output acceptance report

The `incremental-binary-output` saga is accepted for interpreter-driven,
sandboxed seekable file paths. It covers sink semantics, exact byte copying,
canonical WAV copy/transformation, ID3 removal, accepted MPEG-frame extraction,
and Ogg page copy/rewrite with recomputed CRC.

## Accepted contracts

- `append_bytes(path, bytes) -> ok(count)` validates scalar or rank-one logical
  bytes, creates or appends, and implicitly closes/flushes each call.
- `bounded_copy_range` and `bounded_copy_file` require new destinations, exact
  source/output budgets, verified counts, and explicit keep/remove partial-file
  policy.
- `bounded_wav_output` emits a fixed canonical header followed by bounded PCM
  copy or unsigned-8-bit inversion chunks and required odd padding.
- `strip_id3v2` copies an accepted audio descriptor byte-for-byte;
  `extract_mpeg_frames` validates then rescans without retaining a frame list.
- `copy_ogg_page` requires source CRC integrity;
  `rewrite_ogg_page_sequence` substitutes exact u32 sequence/checksum fields
  while preserving lacing and payload bytes.

All format writers are downstream MLPL libraries over generic range reads and
`append_bytes`; no WAV, MP3, ID3, Ogg, or CRC runtime builtin was added. Output
is create-new by contract. Errors before creation leave no destination; errors
after creation follow the caller's cleanup choice. OS write failures can still
leave an externally observable partial file when cleanup is disabled or fails.

## Growing-output peak RSS

Run the opt-in executable acceptance harness:

```sh
just bounded-output-memory-evidence
```

It creates sparse zero sources, copies them through 65,536-byte MLPL
read/append loops, checks exact destination sizes, and uses platform `cmp` as an
independent byte oracle. Each copy runs in a fresh process under
`/usr/bin/time`; the output files are removed with the harness work directory.

Recorded on 2026-08-09 on arm64 macOS 26.5 with `mlpl-repl 0.20.0` reporting
build commit `15d740d7`:

| Output | Append chunks | Peak RSS |
| --- | ---: | ---: |
| 1,048,576 bytes | 16 | 15,859,712 bytes |
| 67,108,864 bytes | 1,024 | 15,974,400 bytes |

Logical output increased 64-fold while measured peak RSS increased 114,688
bytes. Both processes stayed below the enforced 50,331,648-byte ceiling; the
large output itself exceeded that ceiling. The harness also enforces an
8,388,608-byte maximum non-negative growth. These are repeatable executable
ceilings, not universal platform maxima.

The evidence proves bounded resident growth for byte copy at this fixed chunk
size and runtime. It does not claim one resident byte per logical byte: MLPL
still represents byte arrays as f64 cells. Packed u8 would improve density and
possibly throughput, but it is not required for bounded file-path copying
because chunking already caps the live logical-byte vectors.

## Verification summary

The final repository gate discovers 88 native tests across 26 mlplunit suites.
It checks source/catalog/license/link/gitignore/Agentrail policy, capability and
compiler boundaries, every narrated demo family, byte/hash/range oracles,
malformed inputs, cleanup policy, CRC integrity, and compiler numeric/arithmetic
parity. Large RSS evidence remains opt-in because it is platform-specific and
writes a 64 MiB temporary output.

## Remaining blockers and next work

1. **Standalone compiled applications.** `mlpl-build` still rejects generic
   `read_bytes`, `append_bytes`, `args`, and bit-operation calls. Compiler I/O
   parity is the gate for a useful native file-processing CLI.
2. **Binary stdout and non-seekable sinks.** There is no binary stdout writer,
   persistent sink handle, pipe/backpressure lifecycle, or cross-call output
   transaction. File-path output is accepted; Unix streaming is not.
3. **Incremental source/codec state.** Range reads are seekable and stateless,
   not consumable stream handles. MP3 decoding and Vorbis encoding still need
   separately authorized chunk-oriented codec extensions.
4. **Packed bytes.** Packed u8 storage remains a density/performance roadmap
   item, not a bounded-output blocker. Exact arbitrary 64-bit scalar fields also
   remain split-word work unless a concrete consumer requires a native type.

The recommended next saga is standalone file applications after compiler I/O
parity is available. Codec-extension and MP3-to-Ogg work remain gated on the
explicit chunk-oriented extension surface; binary stdout is independently
useful but not required for sandboxed file-to-file transcoding.

# Binary stdout acceptance report

The `binary-stdout-output` saga is accepted for interpreter-driven output from
seekable file ranges to process stdout. It extends the accepted sandboxed
file-path writers; it does not replace their create-new and cleanup semantics.

## Accepted contracts and applications

- `write_stdout(bytes) -> ok(count)` accepts scalar or rank-one logical bytes,
  rejects invalid domain/rank/kind values, preserves call ordering, flushes per
  call, and reports exact counts.
- `bounded_stdout_range` and `bounded_stdout_file` enforce exact contained
  ranges, positive chunk and total-byte budgets, exact read lengths, and exact
  stdout counts while retaining O(`chunk_size`) payload state.
- Demos emit exact raw bytes, a complete canonical PCM WAV, and one
  checksum-preflighted Ogg page. Stdout is binary only; all explanation is on
  stderr, and `exit(0)` prevents final-value contamination.
- Shell oracles compare raw/WAV artifacts byte-for-byte. The captured Ogg page
  is compared with its accepted source range, reparsed, and CRC-verified.

Stdout is irreversible. A failure after earlier successful writes cannot roll
back bytes already consumed by a file, pipe, or process. The writer returns an
error and makes no cross-call transaction claim. Broken-pipe timing remains
OS/scheduler dependent and is not asserted by the deterministic default gate.

## Growing-stdout peak RSS

Run the opt-in executable harness:

```sh
just stdout-memory-evidence
```

It creates sparse 1 MiB and 64 MiB sources, runs each copy in a fresh process,
redirects binary stdout into a regular-file sink, checks exact size and `cmp`
equality, and parses peak RSS from platform `/usr/bin/time`. Narration shares
the metrics/stderr stream and is explicitly checked not to enter stdout.

Recorded on 2026-08-09 on arm64 macOS 26.5 with `mlpl-repl 0.20.0` reporting
build commit `91d5216a`:

| Captured stdout | Writes | Peak RSS |
| --- | ---: | ---: |
| 1,048,576 bytes | 16 | 12,533,760 bytes |
| 67,108,864 bytes | 1,024 | 15,892,480 bytes |

Captured output increased 64-fold while measured peak RSS increased 3,358,720
bytes. Both runs stayed below the enforced 50,331,648-byte ceiling, growth
stayed below 8,388,608 bytes, and the 64 MiB output itself exceeded the RSS
ceiling. These are executable acceptance thresholds for this platform/runtime,
not universal maxima or a throughput claim.

Logical bytes remain f64-backed. Packed u8 could materially improve density and
throughput, but is not required for bounded stdout memory: fixed chunking caps
the live logical-byte vector independently of total output.

## Verification and remaining blockers

The final default gate discovers 93 native tests across 28 mlplunit suites and
checks exact stdout conformance, bounded range/budget behavior, raw/WAV/Ogg
artifacts, compiler boundaries, and all pre-existing repository demos. The 64
MiB RSS harness is opt-in because it is platform-specific and intentionally
expensive.

The remaining blockers are:

1. **Compiler I/O parity.** The adjacent development `mlpl-build` lowers
   `args` and `write_stdout`, but its generated wrapper appends a textual result
   line. It still rejects `read_bytes`, `append_bytes`, and required bit
   operations, so these scripts are not pristine standalone native CLIs.
2. **Binary source and persistent handles.** Binary stdin, consumable source
   handles, explicit backpressure, seekable/persistent sink lifecycle, and
   cross-call transactions remain absent.
3. **Codec extensions.** MP3 decoding and Vorbis encoding still require
   separately authorized chunk-oriented extension contracts and state.
4. **Packed bytes and exact wide scalars.** Packed u8 is a performance/density
   roadmap item rather than a bounded-memory blocker. Exact arbitrary 64-bit
   fields remain split-word values unless a concrete consumer earns a new type.

The recommended next saga remains standalone file applications after the
remaining compiler I/O and entry-point parity lands. Codec-extension work can proceed independently for
interpreter-driven seekable-file pipelines when its extension surface is
authorized.

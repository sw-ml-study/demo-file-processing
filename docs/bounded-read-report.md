# Bounded range-analysis acceptance report

## Decision

The `bounded-range-analysis` saga meets its read-side acceptance criteria.
Seekable files can be traversed through exact validated ranges; histogram
results are invariant across required chunk sizes; WAV metadata inspection
survives every relevant header split without retaining payloads; and sparse
measurements stay within fixed peak-RSS and growth ceilings as artifacts grow.

This accepted bounded analysis, not general streaming. Since this report was
published, sw-MLPL `d3713461` added `append_bytes` for incremental sandboxed
file-path output. The later `write_stdout` sink adds binary process output;
binary stdin/source handles, explicit backpressure, and compiled
application parity remain absent; output claims require their own new evidence.

## Executable evidence

| Surface | Accepted evidence |
| --- | --- |
| Full gate | `just check` passes policy, catalog, fixture, documentation, compiler-boundary, demo, and test checks |
| Native tests | 41 tests pass across 13 mlplunit suites; no ad hoc executable MLPL tests |
| Catalog | 14 rows: 10 runnable and 4 constrained; 4 rows make chunk-bounded memory claims |
| Range conformance | Chunk budgets 1, 7, 64, and 65,536; empty, zero-length, EOF, beyond-EOF, clamping, invalid type/rank/sign/fraction, exact-domain overflow, missing/directory, and sandbox cases |
| Exact windows | Explicit allocation budgets, metadata containment, short-read errors, immutable reader state, and every internal split of a 16-byte window |
| Histogram | Whole-buffer parity for every required chunk budget and empty, repeated, ramp, and all-byte fixtures |
| WAV | Whole-buffer semantic parity for all fixtures; header budgets 1 through 16, 64, and 65,536; odd padding, malformed extents, formats, and chunk budgets |
| Sparse RSS | Histogram remains below 32 MiB over a 16-fold input increase; WAV remains below 32 MiB as payload grows from 1 MiB to 64 MiB; repeat growth remains below 1.1 MiB |
| Demonstrations | Seven narrated recipes explain purpose, input, ownership, operation, and interpretation |

The platform-RSS evidence is opt-in because it is slow and requires macOS or
Linux `time` metrics. The normal gate validates the harness but does not rerun
the large sparse cases.

## Stabilized downstream contracts

The following MLPL interfaces are earned by tests and demonstrations:

- `range_reader(path, chunk_size)` snapshots exact file size and returns
  immutable path/size/offset/budget state;
- `range_read_at(reader, offset, length)` performs validated independent access;
- `range_next(reader)` returns bytes, advanced state, and stable EOF;
- `range_window(reader, offset, length, max_window)` assembles a small exact
  budgeted window across arbitrary read boundaries;
- `range_byte_histogram(path, chunk_size)` returns 256 counts plus byte/chunk
  accounting without retaining earlier chunks; and
- `inspect_wav_ranges(path, chunk_size, max_chunks)` returns PCM and data-range
  metadata without a sample-data field.

Offsets, lengths, file sizes, and budgets are exact non-negative f64 integers
through `2^53-1`; chunk sizes and chunk-count budgets are positive. The file
size is a snapshot: truncation becomes a deterministic short-read/truncation
error and growth outside the snapshot is ignored or rejected by container
length validation. Runtime path sandboxing and OS errors remain `Result`
effects owned by the native runtime.

## Complexity and allocation boundaries

- Reader state and WAV metadata are fixed-sized records.
- A range read materializes at most the requested chunk as ordinary f64 cells,
  not packed bytes.
- A range window is explicitly budgeted; WAV windows never exceed 16 cells.
- Histogram uses O(256n) work and a `256 × chunk_length` f64 equality matrix,
  plus newly allocated 256-cell partial and accumulator arrays.
- WAV inspection is O(chunk count) and skips data/unknown payload bytes by
  validated offsets; it does not validate skipped sample contents.

The histogram is demonstrably memory-bounded but slow: the 1 MiB sparse case
performs 4096 partial reductions at a 256-byte budget. A faster generic grouped
count or histogram primitive is a performance opportunity, not a correctness
or bounded-memory blocker.

## Blockers and deferred claims

1. **Incremental binary output (subsequently unblocked for file paths):**
   `append_bytes` at `d3713461` now provides bounded append calls with implicit
   close/flush. Downstream copy/rewrite and cleanup evidence is in progress;
   binary stdout is now delivered separately through `write_stdout`.
2. **Compiled application parity:** generated applications do not lower byte,
   bit, argument, diagnostic, and exit APIs. Arithmetic parity now passes, but
   the remaining runtime surface still blocks standalone file applications.
3. **Sequential/non-seekable input:** range reads cover seekable paths, not
   binary stdin, backpressure, or a consumable stream handle. This is not needed
   for the next file inspectors but remains a codec/pipeline requirement.
4. **Representation:** bytes occupy f64 cells and arbitrary u64 values require
   split exact words. Packed u8 and native u64 remain deferred until a measured
   operation proves they are necessary.
5. **Output and codecs:** MP3 decode, Vorbis encode, Ogg packetization, and the
   capstone are not implemented; external tools remain oracles only.

Agentrail history associates each implementation commit with its step. Its
audit also reports the separately required completion-metadata commits as
orphans because a step records the implementation `HEAD` observed before
`agentrail complete`; this is a workflow-accounting limitation, not missing
implementation work.

## Recommended next work

Archive this saga and begin `mp3-id3-inspection`. The bounded reader, exact
windows, cross-byte fields, and measured memory behavior make read-only MPEG
frame scanning and bounded ID3 parsing unblocked. Follow with read-only Ogg
container inspection. Keep tag stripping, frame extraction, WAV transforms,
and Ogg rewriting in `incremental-binary-output` until its generic sink is
separately authorized and delivered.

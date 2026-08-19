# Evidence-backed upstream contracts

This downstream repository does not modify `../sw-mlpl`. Each request below is
the smallest general capability motivated by an executable probe. Ordering is
based on what blocks the next planned demo, not on speculative completeness.

The [foundation acceptance report](foundation-report.md) closes the measured
foundation work and separates the unblocked bounded-read path from capabilities
that still require upstream authorization.

The [bounded stdin request](sw-mlpl-bounded-stdin-request.md) is delivered as
`read_stdin_chunk(max_bytes)` with interpreter/compiler parity. The compiled wc
consumer now closes the downstream contract with explicit EOF, cross-read
state, total budgeting, I/O error status, host parity, and 1 MiB/64 MiB RSS
evidence. Whole-input `read_stdin()` remains useful but is not used for this
bounded claim.

The [bounded-read acceptance report](bounded-read-report.md) now demonstrates
that no upstream source API is required for seekable-file histogram, WAV,
MP3/ID3, or Ogg inspection. Repeated exact range reads plus MLPL state are the
accepted downstream contract.

The [MP3/ID3 acceptance report](mp3-id3-report.md) confirms that semantic MPEG
scanning and budgeted ID3v2 inspection need no format-specific upstream API.
Its audio descriptor is ready for future output work, but copying, stripping,
and extraction remain gated on the generic incremental sink below.

The [Ogg acceptance report](ogg-report.md) likewise confirms that page/lacing,
packet continuation, split-word granules, and CRC verification need no Ogg-
specific upstream API. Its page descriptors are ready for future copy/rewrite;
the generic sink remains the blocker.

## Delivered: bounded range reads

The configured interpreter already supplies:

```text
read_bytes(path, offset, length) -> Result<Array, Error>
file_size(path) -> Result<Number, Error>
```

The native mlplunit suite verifies middle ranges, EOF clamping, beyond-EOF
empty results, and zero-length reads. This unblocks bounded random-access
parsing and invalidates the older research assumption that range I/O is absent.
No upstream request is needed before the in-memory hexdump/histogram, bitfield,
or WAV foundation steps.

## Delivered: documented numeric `mlpl-build`

### Evidence

`probes/compiler_arithmetic.mlpl`:

```mlpl
reduce_add((iota(8) + 1) * 2)
```

The selected adjacent development build now compiles the expression and its
artifact prints `72`, matching the interpreter. `scripts/check-compiler` has
replaced the former expected failure with positive parity.

### Accepted evidence

- The arithmetic probe builds without modifying its MLPL source.
- The artifact prints the same value as the interpreter (`72`).
- Existing compiler parity tests remain green.
- This downstream expected-failure check is replaced by positive parity.

This resolves the minimized arithmetic-generation defect. File applications
remain blocked by the separate byte/process/bit lowering boundary below.

## Gate: compiled application runtime parity

### Evidence

The interpreter passes probes for `args`, `read_stdin`, stdout/stderr, exit
status, whole/range byte reads, and bit operations. The adjacent development
`mlpl-build` now lowers arguments, binary stdout, whole/range reads, file size,
append/write, and bit operations, but the generated wrapper still adds textual
Result output after binary stdout.

The expanded [compiled process conformance report](compiler-process-conformance.md)
also verifies `arg/1` lowering and records the remaining semantic defects:
compiled invalid bytes are now rejected, while runtime write-error acceptance
remains open. `read_stdin`, `print`, `eprint`, and `exit` now lower with the
measured wrapper behavior.
Process parity therefore requires shared validation/error behavior as well as
additional match arms; lowering a call name alone is not acceptance.

The [compiled byte-application report](compiled-byte-applications.md) attempts
the actual hexdump and histogram demos. With the repository supplied as
`--source-dir`, both now resolve their include graphs. The selected development
binary also lowers functions, control flow, Results/records, byte I/O, and bits;
both real sources now pass comparison, tally, indexing, and equality lowering.
Hexdump stops at `pow/2` and histogram at `fill/2`, matching flattened controls.

The [compiled format-application report](compiled-format-applications.md)
repeats the experiment with the real bounded WAV copy/invert and Ogg page
copy/rewrite programs. Both pass the earlier compiler rungs and hit the same
`concat/2` wall before format-specific lowering, artifact byte parity, or bounded-
memory auditing can begin. No new codec builtin is requested: the existing MLPL
algorithms need the generic compiler surface first.

The [standalone artifact audit](standalone-artifact-audit.md) confirms that
numeric and partial-stdout control artifacts run in a clean source-free
directory without a named parser/REPL/evaluator dynamic dependency. This
isolates the blocker to application coverage and semantics rather than an
artifact-launch mechanism; the control is explicitly not accepted as a useful
file-processing CLI.

The consolidated [standalone application assessment](standalone-report.md)
orders the remaining generic work: comparison and later array/text lowering;
accepted sink-error propagation; clean process entry/status semantics; then positive
byte and format artifact parity plus a repeated clean-environment audit. Codec
extensions and binary source handles are tracked separately and do not explain
the current compile failures.

The standalone request is also available as a self-contained sendable handoff:
[`sw-mlpl-standalone-compiler-handoff.md`](sw-mlpl-standalone-compiler-handoff.md).

The [unified media inspector](media-inspector.md) demonstrates that no new
upstream format builtin is required for higher-level interpreter applications:
existing bounded file, endian, bit, Result, record, and process surfaces compose
successfully. Its remaining upstream boundary is the already documented
compiler parity needed to turn the same MLPL application into a native artifact.
The [media doctor](media-doctor.md) further demonstrates that Result errors,
records, control flow, and format-specific policy compose at the interpreter
level; it introduces no new upstream format or codec request.
The [bounded WAV transformation app](wav-transform-app.md) likewise composes
existing interpreter range reads, append output, Results, and record/control
flow. Its only upstream gap is the same queued compiler parity; no WAV-specific
runtime or codec builtin is requested.

The complete [interpreter media-apps acceptance](interpreter-media-apps-report.md)
confirms the higher-level application objective is unblocked in the interpreter.
It does not alter the broader upstream request: compiling the same MLPL
application sources now waits on remaining operation and process parity after
source, functions, control flow, Results/records, byte I/O, and bits appeared.

## Upstream coordination status

As of 2026-08-17, the adjacent sw-MLPL repository records this downstream
contract in `docs/companion-demo-file-processing.md`. Its
`docs/future-sagas-queue.md` expands the compiler track in the same measured
gate order: `compiler-source-loading` (B0), `compiler-functions` (B1),
`compiler-control-flow` (C), `compiler-read-bytes` (D),
`compiler-process-semantics` (D2), and `compiler-bit-ops` (E).

Saga A—the compiled `CVal` plus string/`args`/`arg`/`write_stdout` groundwork—is
recorded upstream as shipped. B0 (`compiler-source-loading`) shipped on
2026-08-10 and is accepted here through real-source checks using `--source-dir`.
Later compiler rungs through byte I/O and bits have appeared in the selected
development binary. Comparison, `tally/1`, `take/3`, `floor`, `type_of/1`, and
`equal/2` lowering are now accepted here. This repository retains exact
`pow/2`, `fill/2`, `concat/2`, `to_string/1`, and narrated-entry change
detectors while positively compiling and executing the standalone wc filter.

### Minimum acceptance

Shared runtime operations, with interpreter and compiled implementations using
the same semantics:

- `args`, `print`, `eprint`, and `exit`;
- `read_bytes(path)` and `read_bytes(path, offset, length)`;
- `file_size` and `write_bytes`;
- the existing fixed-width bit-operation family;
- Result errors, sandbox/path rules, EOF behavior, and exit codes matching the
  interpreter probes.

The compiled fixture suite must match interpreter stdout, stderr, exit status,
byte values, and errors. A produced application must run without source, parser,
REPL, or interpreter at runtime. This gate belongs before the standalone-
application saga, not before the next in-memory demos.

## Delivered: incremental sandboxed file-path sink

sw-MLPL `d3713461` provides `append_bytes(path, bytes) -> ok(count)`, which
validates and appends one bounded chunk with implicit per-call close/flush. See
the [downstream conformance contract](append-bytes.md). This clears bounded file
copy/rewrite/extraction for interpreter-driven sandboxed paths without adding
format-specific builtins.

## Delivered: non-seekable binary stdout sink

`write_stdout(bytes) -> ok(count)` now supplies ordered, per-call-flushed binary
process output. Downstream exact-byte/count/stderr-separation conformance is
recorded in [the stdout contract](write-stdout.md). Bounded range reads,
`append_bytes`, and `write_stdout` cover interpreter-side seekable input to file
or stdout output.

The [stdout acceptance report](stdout-report.md) records exact 64 MiB captured
stdout above the RSS ceiling with 3,358,720 bytes measured growth across a
64-fold output increase. The downstream non-seekable output subset is accepted.

## Remaining gate: binary source and persistent handles

The runtime still does not provide binary stdin, explicit backpressure, or
consumable source/sink handles. Transcoding from seekable files can proceed once
codec extensions exist; true stdin-driven streaming still needs these effects.

The preferred missing surface is compositional rather than codec-specific. A
sink must provide bounded writes, partial-write handling, flush/close cleanup,
sandboxing, offsets beyond f64 ambiguity, and a memory high-water invariant. A
later non-seekable source should add explicit EOF, backpressure, and equivalent
error/lifecycle semantics. Exact API spelling should be earned by the
incremental-output and codec sagas; do not add MP3/Ogg builtins.

Minimum sink acceptance includes byte-identical output for write chunk sizes 1,
7, 64, and 65,536; injected partial/failed writes; outputs larger than the
memory budget; and measured resident memory proportional to chunk plus writer
state rather than total output size. If a sequential source is added, it must
also reproduce the already accepted range-reader results across split fields.

The sandboxed file-path subset now satisfies those criteria downstream. The
[bounded-output report](bounded-output-report.md) records a byte-identical
64 MiB output above the RSS ceiling with only 114,688 bytes measured growth.
This does not satisfy binary stdin, persistent-handle, explicit backpressure,
or compiler-lowering requirements; those remain the genuine upstream gaps.

## Deferred: packed bytes and exact 64-bit fields

Current reads allocate an ordinary f64 per byte. That is inefficient, but it
does not block tiny foundation fixtures or bounded range parsing. Request a
packed `u8`/typed-array representation when density or throughput becomes a
concrete target. The accepted output measurement shows it is not required to
bound file-copy RSS, because fixed chunking already bounds live f64 byte cells.

Ogg granule positions and other 64-bit fields cannot be represented as one
exact f64 across their full domain. Foundation code should first use two exact
32-bit words. A native unsigned 64-bit or typed scalar request should follow
only if that representation prevents a concrete operation or compiler parity.

## Gate: confined file modification time

The demo-extensions model picker needs the same generic timestamp surface as
the date-index library here. Pure MLPL sorting and UTC formatting are now
delivered; the selected interpreter currently has no usable
`file_metadata(...).modified_unix_ms` operation, so only live acquisition and
filesystem parity remain blocked.

The active upstream saga is implementing a confined lookup returning an exact integral
UTC Unix-millisecond value, with explicit stable errors for unavailable or
unrepresentable timestamps and unchanged sandbox/traversal/symlink protection.
This repository owns deterministic sorting/ties, pure UTC formatting,
unavailable-value presentation, and mlplunit coverage now. It will add bounded
live-path and platform-parity probes when the rebuilt interpreter arrives. It
does not request a model picker, directory walker, locale formatter, or
external `stat` wrapper.

The complete downstream acceptance contract and resume trigger are in the
[file-date metadata plan](file-date-metadata-plan.md).

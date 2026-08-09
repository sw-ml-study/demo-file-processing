# Handoff to sw-MLPL: standalone file-application blockers

## Request

`demo-file-processing` has completed its standalone-application assessment.
The verdict is **not accepted**: the interpreter supports the required file
algorithms, but `mlpl-build` cannot yet produce a useful native hexdump,
histogram, WAV, or Ogg application.

Please treat the ordered compiler/runtime items below as the upstream unblock
for this downstream repository. The downstream default gate contains exact
change detectors and can resume positive parity work as soon as the first
boundary moves.

## Coordination status

The sw-MLPL repository has acknowledged this contract in
`docs/companion-demo-file-processing.md` and expanded
`docs/future-sagas-queue.md` into the corresponding B0/B1/C/D/D2/E compiler
rungs. Saga A is shipped; the remaining rungs are queued rather than delivered.
Downstream expected-failure probes therefore remain authoritative until a
rebuilt development compiler changes their observed behavior.

## What is already accepted downstream

Through the selected `mlpl-repl` build, native mlplunit tests and exact shell
oracles accept:

- whole-file and bounded offset/length `read_bytes`;
- `file_size`, `write_bytes`, and incremental `append_bytes`;
- validated logical bytes and fixed-width bit operations;
- interpreter `args`, text stdin/stdout/stderr, and exit status;
- exact binary `write_stdout` with counted writes and stderr separation;
- bounded hexdump/histogram, MP3/ID3 and Ogg inspection, WAV parsing;
- bounded file copy/rewrite/extraction and raw/WAV/Ogg binary stdout; and
- growing file-output and stdout RSS evidence under fixed chunk budgets.

The full downstream gate currently passes 100 native mlplunit tests across 30
suites plus exact binary, CRC, narration, compiler-boundary, and artifact-audit
oracles. The missing capability is compiler parity, not an absent downstream
file-format algorithm.

## Exact observed compiler boundary

The adjacent development `mlpl-build` has no version flag, so the executable
probes named below are the authority.

### Partial process lowering

- `args()` and `arg(i)` lower.
- `write_stdout(bytes)` lowers.
- Generated `main` always prints the returned numeric result, contaminating
  binary output. `write_stdout([0,255])` produces bytes `[0,255]` followed by
  text `2\n`.
- Invalid `[256,-1,1.5]` is coerced to `[255,0,1]` instead of being rejected
  before output like the interpreter.
- Compiled stdout code discards `write_all`/`flush` failures and returns the
  requested count.
- `read_stdin`, `print`, `eprint`, and `exit` are rejected as unsupported.

See `scripts/check-compiler` and
[`compiler-process-conformance.md`](compiler-process-conformance.md).

### Real byte applications

Direct compilation of both existing applications fails at the first include:

- `demos/bytes/hexdump.mlpl`
- `demos/bytes/histogram.mlpl`

The error says `include` is unsupported and asks for already-resolved source.
The downstream check then mechanically concatenates the exact dependencies in
a temporary file. Both resolved programs next fail at unsupported `FnDef`.

See `scripts/check-compiled-byte-apps` and
[`compiled-byte-applications.md`](compiled-byte-applications.md).

### Real format applications

The same experiment is performed with useful bounded-output applications:

- `demos/wav/bounded_output.mlpl` — canonical copy plus unsigned-8-bit sample
  inversion;
- `demos/ogg/bounded_output.mlpl` — page copy plus sequence/CRC rewrite.

Direct sources fail on `include`; dependency-concatenated sources fail on
`FnDef`. No native format artifact exists, so downstream cannot yet compare
bytes, reparse output, test malformed-file statuses, or measure compiled RSS.

See `scripts/check-compiled-format-apps` and
[`compiled-format-applications.md`](compiled-format-applications.md).

### Artifact mechanism is not the blocker

Numeric and partial-stdout control artifacts compile and run from a fresh
source-free directory under `env -i`. `otool -L`/`ldd` finds no named
`mlpl-repl`, `mlpl-parser`, or `mlpl-eval` dynamic dependency. The compiler can
produce genuine executables for its narrow supported subset; application
coverage and semantics are the blocker.

See `scripts/check-standalone-artifact` and
[`standalone-artifact-audit.md`](standalone-artifact-audit.md).

## Ordered upstream unblock

Please implement or expose these in dependency order:

1. Resolve source-relative `include` graphs before lowering.
2. Lower user functions and calls, conditionals/loops, Result propagation,
   records, and field access with interpreter-equivalent behavior.
3. Share exact byte validation and I/O error propagation; do not coerce invalid
   byte values or discard sink errors.
4. Lower bounded `read_bytes`, `file_size`, `append_bytes` or equivalent binary
   output, plus the array/bit/text operations used by the existing demos.
5. Provide application entry-point semantics with pristine binary stdout,
   stderr, useful nonzero exit status, and required stdin behavior—without an
   automatic textual result trailer.
6. Compile the existing hexdump and histogram and compare interpreter/artifact
   streams and statuses across their current fixture suites.
7. Compile bounded WAV or Ogg output, compare exact bytes, semantically reparse
   the artifact, test failure statuses, and measure compiled peak RSS.

No format-specific hexdump, histogram, WAV, Ogg, or MP3 builtin is requested.
The downstream MLPL algorithms should remain the implementation under test.

## Not required for the first unblock

These are separate later roadmap items and should not delay the first useful
standalone file application:

- packed u8 storage—chunking already bounds logical-byte memory;
- arbitrary exact 64-bit scalar fields—existing code uses split words;
- binary stdin, persistent handles, and explicit backpressure—seekable bounded
  file reads are sufficient for the first compiled hexdump/WAV/Ogg target;
- MP3 decoder and Vorbis encoder extensions—needed for the later codec saga,
  not for compiler parity of existing byte/container applications; and
- dynamic extension loading—also later than the first generic file artifact.

## Downstream resume trigger

After rebuilding the adjacent development `mlpl-build`, run from
`demo-file-processing`:

```sh
./scripts/check-compiler
./scripts/check-compiled-byte-apps
./scripts/check-compiled-format-apps
./scripts/check-standalone-artifact
just check
```

The expected-failure checks intentionally fail when upstream support advances.
The first of these changes is enough to notify the downstream agent:

- a real demo no longer fails on `include`;
- a dependency-concatenated demo no longer fails on `FnDef`;
- a previously unsupported process or byte-I/O call lowers; or
- compiled stdout no longer contains its textual trailer and matches
  interpreter validation/error behavior.

At that point downstream should replace the affected negative assertion with a
positive artifact-parity test and continue in the same ordered ladder. Full
success is not required before sending the update; the first moved boundary is
actionable.

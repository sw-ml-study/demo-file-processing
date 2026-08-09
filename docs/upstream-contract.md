# Evidence-backed upstream contracts

This downstream repository does not modify `../sw-mlpl`. Each request below is
the smallest general capability motivated by an executable probe. Ordering is
based on what blocks the next planned demo, not on speculative completeness.

The [foundation acceptance report](foundation-report.md) closes the measured
foundation work and separates the unblocked bounded-read path from capabilities
that still require upstream authorization.

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
status, whole/range byte reads, and bit operations. `mlpl-build` rejects
`args/0`, `read_bytes/1`, and `band/2` during lowering.

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

## Gate: incremental binary sink and non-seekable source

Bounded range reads now cap seekable-file input allocation and MLPL carries
state across arbitrary boundaries. They do not provide bounded output,
non-seekable binary stdin, backpressure, or a consumable stream handle. WAV
transformation, byte-preserving rewrites, and transcoding still need those
effects.

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

## Deferred: packed bytes and exact 64-bit fields

Current reads allocate an ordinary f64 per byte. That is inefficient, but it
does not block tiny foundation fixtures or bounded range parsing. Request a
packed `u8`/typed-array representation only after measurements show the range
API cannot meet a concrete memory or throughput target.

Ogg granule positions and other 64-bit fields cannot be represented as one
exact f64 across their full domain. Foundation code should first use two exact
32-bit words. A native unsigned 64-bit or typed scalar request should follow
only if that representation prevents a concrete operation or compiler parity.

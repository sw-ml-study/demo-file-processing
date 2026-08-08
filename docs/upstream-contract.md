# Evidence-backed upstream contracts

This downstream repository does not modify `../sw-mlpl`. Each request below is
the smallest general capability motivated by an executable probe. Ordering is
based on what blocks the next planned demo, not on speculative completeness.

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

## Defect: restore documented numeric `mlpl-build`

### Evidence

`probes/compiler_arithmetic.mlpl`:

```mlpl
reduce_add((iota(8) + 1) * 2)
```

The expression is documented as lowered, but generated Rust fails because the
`ApplyBinopExt` trait is not in scope. `scripts/check-compiler` keeps this as an
expected failure while a simpler numeric expression proves the compiler itself
works.

### Minimum acceptance

- The arithmetic probe builds without modifying its MLPL source.
- The artifact prints the same value as the interpreter (`72`).
- Existing compiler parity tests remain green.
- This downstream expected-failure check is replaced by positive parity.

This defect does not block interpreter-only foundation demos, but it blocks an
honest claim that the documented numeric compiler subset is currently usable.

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

## Gate: incremental binary source and sink

Bounded range reads cap input allocation but do not provide a consumable stream
or bounded output. MP3 scanning, Ogg packet reconstruction, WAV transformation,
and transcoding eventually need state carried across arbitrary chunk boundaries.

The preferred surface is compositional rather than codec-specific. It must
provide bounded binary reads and writes, explicit EOF/short-I/O errors, cleanup,
sandboxing, offsets beyond f64 ambiguity, and a memory high-water invariant.
Exact API spelling should be earned by the bounded-file-streaming saga; do not
add MP3/Ogg builtins.

Minimum acceptance includes identical results for chunk sizes 1, 7, 64, and
65,536; fields split across chunks; inputs larger than the memory budget;
bounded writes; and measured resident memory proportional to chunk plus parser
state rather than file size.

## Deferred: packed bytes and exact 64-bit fields

Current reads allocate an ordinary f64 per byte. That is inefficient, but it
does not block tiny foundation fixtures or bounded range parsing. Request a
packed `u8`/typed-array representation only after measurements show the range
API cannot meet a concrete memory or throughput target.

Ogg granule positions and other 64-bit fields cannot be represented as one
exact f64 across their full domain. Foundation code should first use two exact
32-bit words. A native unsigned 64-bit or typed scalar request should follow
only if that representation prevents a concrete operation or compiler parity.

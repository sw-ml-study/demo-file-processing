# Compiled format applications

## Chosen applications

The standalone saga attempts two existing bounded binary-output programs:

- [`demos/wav/bounded_output.mlpl`](../demos/wav/bounded_output.mlpl)
  canonically copies a WAV with an odd padded unknown chunk and separately
  inverts unsigned 8-bit samples using two-byte chunks;
- [`demos/ogg/bounded_output.mlpl`](../demos/ogg/bounded_output.mlpl) copies a
  checksum-valid Ogg page, rewrites its sequence number across seven-byte chunk
  boundaries, recomputes CRC, and reparses the output.

These are useful format applications rather than format-name probes. MLPL owns
RIFF/Ogg parsing, validation, endian fields, Ogg CRC, transformation decisions,
bounded traversal, and output invariants. The runtime owns range reads and
sandboxed append calls. Existing native mlplunit suites cover truncated and
malformed lengths, budgets, endian boundaries, CRC failures, sequence rewrites,
short chunks, cleanup policy, and unsupported WAV variants.

## Compilation evidence

`scripts/check-compiled-format-apps` attempts each real source file and asserts
the current boundary:

1. With `--source-dir` set to the repository root, both real applications now
   resolve their repository-relative `include` graphs. This confirms upstream
   `compiler-source-loading` (B0), shipped 2026-08-10.
2. The selected development binary lowers user functions, after which both
   expanded applications fail on unsupported `If`. Temporary
   dependency-concatenated controls reach the same boundary.

No WAV or Ogg native artifact is produced, so binary I/O parity and bounded
artifact memory cannot yet be measured. Claiming a standalone copy tool from
the successful interpreter path would be an interpreter-wrapper claim, which
does not satisfy this repository's acceptance definition.

These applications still require conditionals, records and field access,
Result propagation, bounded
`read_bytes`, `file_size`, `append_bytes`, removal/cleanup effects, text
diagnostics, exit status, and broad array operations. Ogg additionally requires
the fixed-width bit family; both require exact byte validation rather than the
compiler runtime's currently measured coercion.

## Status and next action

This step is implementation-blocked by the general compiler surface, not by a
missing WAV or Ogg algorithm. The repository retains the negative oracle in
`just check`; when upstream support lands, that deliberate expected failure
will force replacement with artifact execution, byte comparison, semantic
reparse, malformed-input status checks, and interpreter/compiler parity.

The clean-environment artifact audit cannot truthfully start until at least one
of these applications produces a native executable. It can still be specified
as an acceptance contract, but there is currently no artifact to audit.

## Reproduction

```sh
just tests tests/wav
just tests tests/ogg
./scripts/check-wav-demo
./scripts/check-ogg-demos
./scripts/check-compiled-format-apps
just check
```

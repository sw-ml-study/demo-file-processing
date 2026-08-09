# Standalone artifact audit

## Acceptance target

A standalone file-processing claim requires a useful native application that
runs without MLPL source, parser, REPL, or interpreter; accepts arguments;
performs binary input/output; separates diagnostics; returns useful statuses;
and matches interpreter success and failure behavior.

No hexdump, histogram, WAV, or Ogg artifact currently reaches native artifact
production. Their measured compiler blockers are recorded in the
[byte-application](compiled-byte-applications.md) and
[format-application](compiled-format-applications.md) reports. Therefore this
step cannot complete the intended file-application audit.

## Audit control

`scripts/check-standalone-artifact` proves that the audit method itself works
on the compiler subset that does produce artifacts:

1. compile the numeric reduction probe and partial binary-stdout probe;
2. place only the resulting executables in a fresh directory outside the
   repository;
3. execute them with an empty environment except for a minimal system `PATH`;
4. assert exact stdout, empty stderr, and successful status;
5. verify the numeric output is exactly `28`;
6. verify the current partial stdout bytes are exactly `[0, 255]` followed by
   the known generated textual trailer `2\n`; and
7. inspect dynamic dependencies with `otool -L` or `ldd`, rejecting named
   `mlpl-repl`, `mlpl-parser`, or `mlpl-eval` dependencies.

This demonstrates that supported compiler artifacts execute without source or
an interpreter process at runtime. It does not turn the numeric probe or the
contaminated stdout probe into a useful file-processing application.

## Blocked assertions

The application audit still has no artifact on which to verify:

- file arguments and missing/malformed-file errors;
- bounded binary reads and writes;
- pristine binary stdout without a generated trailer;
- stderr diagnostics and nonzero exit statuses;
- byte validation and output-error propagation parity;
- byte-identical WAV/Ogg output and semantic reparse; or
- peak RSS of a compiled bounded-I/O application.

The smallest unblock remains generic compiler source loading, user functions
and control flow, Results, byte I/O, process semantics, and the array/bit
operations already enumerated in the upstream contract. Once one real
application compiles, this control must be replaced or extended with that
artifact's full fixture matrix.

## Reproduction

```sh
./scripts/check-standalone-artifact
./scripts/check-compiled-byte-apps
./scripts/check-compiled-format-apps
just check
```

# Compiled process conformance

## Scope

This report compares the selected interpreter with the adjacent development
`mlpl-build` for the process surface required by a standalone file-processing
application. The compiler exposes no version flag, so the executable probes in
`scripts/check-compiler` are the authority; claims are intentionally limited to
the behavior they reproduce.

## Exact observations

| Surface | Interpreter contract | Development compiler observation | Status |
|---|---|---|---|
| `args()` | Returns arguments after the MLPL separator as language strings | Lowers to a string list; `write_stdout(args())` emits `alpha\nbeta`, then generated `main` appends `10\n` | Partial |
| `arg(i)` | Selects one argument with normal language error behavior | `write_stdout(arg(1))` emits `beta`, then generated `main` appends `4\n` | Partial |
| `write_stdout(bytes)` | Validates scalar/rank-one integral bytes in `0..=255`, writes exact bytes, returns `Result` count, and preserves stderr separation | Lowers and writes, but generated `main` appends the textual count. Invalid `[256, -1, 1.5]` is silently coerced to bytes `[255, 0, 1]` and followed by `3\n` | Not conformant |
| `read_stdin()` | Reads process text stdin | Rejected as `unsupported construct: fncall read_stdin/0` | Missing |
| `print(value)` | Writes text stdout | Rejected as `unsupported construct: fncall print/1` | Missing |
| `eprint(value)` | Writes text stderr | Rejected as `unsupported construct: fncall eprint/1` | Missing |
| `exit(status)` | Terminates with the requested status and prevents REPL result output | Rejected as `unsupported construct: fncall exit/1` | Missing |
| Runtime write failure | Returns a language error for the caller to propagate | Compiled runtime discards `write_all`/`flush` errors and returns the requested byte count | Not conformant |

The positive lowering is useful evidence, but it is not usable standalone CLI
parity. In particular, a binary-producing program cannot suppress the wrapper
trailer, cannot select a meaningful failure status, and does not share the
interpreter's byte validation or output-error semantics.

## Acceptance boundary

The process portion of the standalone saga remains blocked until a compiled
artifact can:

1. accept arguments with interpreter-equivalent indexing and errors;
2. write pristine binary stdout with no generated trailer;
3. reject invalid bytes before output and propagate sink failures;
4. keep diagnostics on stderr and return useful exit statuses; and
5. provide the stdin behavior actually required by the chosen application.

File applications additionally require compiler parity for bounded
`read_bytes`, `file_size`, `append_bytes` or an equivalent sink, and the fixed
width bit operations used by format code.

## Reproduction

```sh
./scripts/check-process-io
./scripts/check-write-stdout
./scripts/check-compiler
just check
```

Interpreter executable behavior remains covered by native mlplunit suites in
`tests/capabilities`; compilation and process stream/status behavior require
the shell-level artifact oracle because mlplunit does not build native
executables or own their host process streams.

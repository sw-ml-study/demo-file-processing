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
| `args()` | Returns arguments after the MLPL separator as language strings | Lowers to a string list; `write_stdout(args())` emits `alpha\nbeta`, then generated `main` appends `ok(10)\n` | Partial |
| `arg(i)` | Selects one argument with normal language error behavior | `write_stdout(arg(1))` emits `beta`, then generated `main` appends `ok(4)\n` | Partial |
| `write_stdout(bytes)` | Validates scalar/rank-one integral bytes in `0..=255`, writes exact bytes, returns `Result` count, and preserves stderr separation | Valid bytes are exact but generated `main` appends `ok(count)`. Invalid `[256, -1, 1.5]` now emits a language `err(...)` without binary bytes | Partial |
| `read_stdin()` | Reads process text stdin | Lowers and returns exact piped text; generated `main` appends a newline when rendering the returned string | Partial |
| `print(value)` | Writes text stdout | Lowers; `print("stdout")` writes once for the call and once when generated `main` renders the returned value | Partial |
| `eprint(value)` | Writes text stderr | Lowers; writes once to stderr, while generated `main` also renders the returned value on stdout | Partial |
| `exit(status)` | Terminates with the requested status and prevents REPL result output | `exit(7)` produces status 7 with empty stdout/stderr | Pass for probe |
| Runtime write failure | Returns a language error for the caller to propagate | Compiled runtime discards `write_all`/`flush` errors and returns the requested byte count | Not conformant |

The positive lowering is useful evidence, but it is not usable standalone CLI
parity. In particular, a binary-producing program cannot suppress the wrapper
trailer, cannot select a meaningful failure status, and does not share the
interpreter's exact Result rendering or accepted output-error semantics.

## Acceptance boundary

The process portion of the standalone saga remains blocked until a compiled
artifact can:

1. accept arguments with interpreter-equivalent indexing and errors;
2. write pristine binary stdout with no generated trailer;
3. preserve the now-observed invalid-byte rejection and propagate sink failures;
4. keep diagnostics on stderr and return useful exit statuses; and
5. provide the stdin behavior actually required by the chosen application.

File applications now have bounded `read_bytes`, `file_size`, append/write, and
fixed-width bit lowering; their first measured application gap is `eq/2`.

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

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
| `args()` | Returns arguments after the MLPL separator as language strings | Lowers to a string list; Result-valued explicit output has no generated trailer | Pass for tested process surface |
| `arg(i)` | Selects one argument | The wc artifact uses `arg` for `--help`, rejects unknown/extra arguments, and returns useful status | Pass for tested artifact |
| `write_stdout(bytes)` | Validates scalar/rank-one integral bytes in `0..=255`, writes exact bytes, returns `Result` count, and preserves stderr separation | Exact output has no generated trailer; invalid values and a closed consumer return errors that become non-zero process results through `?` | Pass |
| `read_stdin()` | Reads process text stdin | Lowers exact whole-input text, but is intentionally absent from the bounded wc source | Pass for whole-input use only |
| `read_stdin_chunk(max_bytes)` | Returns at most the positive exact budget as raw bytes plus explicit EOF; errors are Results | The wc artifact repeatedly reads one byte, preserves state across reads, and propagates read errors through `?` | Pass |
| `print(value)` | Writes text stdout | Lowers; `print("stdout")` writes once for the call and once when generated `main` renders the returned value | Partial |
| `eprint(value)` | Writes text stderr | Lowers; writes once to stderr, while generated `main` also renders the returned value on stdout | Partial |
| `exit(status)` | Terminates with the requested status and prevents REPL result output | `exit(7)` produces status 7 with empty stdout/stderr | Pass for probe |
| Runtime write failure | Returns a language error for the caller to propagate | Closed-pipe acceptance produces a `write_stdout` diagnostic and non-zero status | Pass for `write_stdout` |

The process surface is now sufficient for the bounded wc CLI: explicit output
is pristine, final Results control status without a trailer, and read/write
errors propagate. Broader applications retain separate generic lowering gaps.

## Acceptance boundary

The bounded wc artifact now demonstrates that a compiled artifact can:

1. accept arguments with interpreter-equivalent indexing and errors;
2. write pristine binary stdout with no generated trailer;
3. preserve the now-observed invalid-byte rejection and propagate sink failures;
4. keep diagnostics on stderr and return useful exit statuses; and
5. consume bounded raw stdin with explicit EOF and cross-read state.

File applications now have bounded `read_bytes`, `file_size`, append/write, and
fixed-width bit lowering; their remaining measured gaps are independent of the
accepted stdin process path.

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

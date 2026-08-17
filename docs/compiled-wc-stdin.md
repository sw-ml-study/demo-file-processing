# Standalone compiled wc-style stdin filter

`just compiled-wc` compiles `demos/files/wc_stdin.mlpl` to
`target/demo-bin/mlpl-wc`. The native artifact reads stdin and prints LF-line,
ASCII-delimited word, and physical byte counts:

```sh
just compiled-wc
printf 'one two\n' | target/demo-bin/mlpl-wc
```

The default gate compiles the source, runs mixed CRLF/LF/UTF-8, empty, and
terminated inputs, compares the mixed counts with host `wc -l -w -c`, and runs
the artifact under `env -i` from its temporary location. Dynamic dependency
inspection rejects a named parser, REPL, or evaluator dependency.

The current `read_stdin()` blocks until EOF and returns the complete input as a
string. `tokenize_bytes` then creates the logical-byte array. This is a genuine
standalone Unix filter and compiler milestone, but it does **not** satisfy the
project's target pipeline requirement: live memory is `O(input bytes)` and it
is not a bounded streaming implementation. Words use only ASCII TAB/LF/VT/FF/CR/SPACE
as delimiters; bytes are UTF-8 encoding bytes, not Unicode character counts.

The reusable record-valued wc library remains interpreter-only because current
code generation infers some record state parameters as `DenseArray`, producing
`CVal`/`DenseArray` Rust type errors. The compiled filter deliberately uses
scalar state while preserving the same tested counting policy.

Replacement is gated on the explicit
[bounded incremental stdin contract](sw-mlpl-bounded-stdin-request.md). Slicing
or chunking the result of `read_stdin()` is not an accepted workaround.

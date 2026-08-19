# Standalone compiled wc-style stdin filter

`just compiled-wc` compiles `demos/files/wc_stdin.mlpl` to
`target/demo-bin/mlpl-wc`. The native artifact reads stdin and prints LF-line,
ASCII-delimited word, and physical byte counts:

```sh
just compiled-wc
printf 'one two\n' | target/demo-bin/mlpl-wc
target/demo-bin/mlpl-wc --help
```

The artifact calls `read_stdin_chunk(1)` until explicit EOF. It folds each byte
immediately and retains only line/word/byte counters plus the previous
in-word bit. A 64 MiB exact total-byte budget is checked before a newly read
byte is folded. Budget overflow exits with status 2 and no count output;
incremental read errors and `write_stdout` failures propagate through `?` to a
non-zero process result.

The only CLI option is `--help`; unknown or extra arguments fail with usage on
stderr. Chunk and total limits are deliberately fixed policy constants because
the current compiler cannot yet lower Result-valued numeric argument parsing
through the required scalar branches without `CVal`/`DenseArray` type errors.

The default gate compiles the source, runs mixed CRLF/LF/UTF-8, empty, and
terminated inputs, and splits every multi-byte UTF-8 sequence and word across
one-byte reads. Host `wc -l -w -c` agrees. A cheap compiler variant exercises
the total-budget exit, a deliberately closed pipe exercises stdout-error
propagation, and the normal artifact runs under `env -i` from its temporary
location. Dynamic dependency inspection rejects a named parser, REPL, or
evaluator dependency. The source gate rejects any fallback to `read_stdin()`.

Words use only ASCII TAB/LF/VT/FF/CR/SPACE as delimiters; bytes are UTF-8
encoding bytes, not Unicode character counts. Consequently, splitting UTF-8
code units across reads does not change the answer.

`just compiled-wc-memory-evidence` measures complete 1 MiB and 64 MiB stdin
runs. On the recorded arm64 macOS run, peak RSS was 2,080,768 and 2,080,768
bytes respectively (reported non-negative growth: zero), below the 48 MiB
absolute and 8 MiB growth ceilings. Counts matched host `wc`; the 64-fold input
increase therefore did not drive resident growth. This supports `O(chunk_size)`
payload memory for this implementation. The one-byte buffer favors a minimal,
observable contract over throughput; packed bytes or a native fold could
improve performance without changing the boundedness result.

The reusable record-valued wc library remains interpreter-oriented because
record-state parameter lowering still has separate constraints. The compiled
filter deliberately uses scalar state while preserving the same mlplunit-tested
counting and budget policies.

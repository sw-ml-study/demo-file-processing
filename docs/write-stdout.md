# Binary stdout sink conformance

The selected sw-MLPL interpreter provides:

```text
write_stdout(bytes) -> ok(count) | err(error)
```

The repository's native mlplunit suite establishes that scalar and rank-one
logical byte arrays are accepted, empty writes return zero, and invalid domain,
rank, fractional, and value-kind inputs return `Err`. The shell oracle performs
four calls and observes exactly these eight stdout bytes, with no textual REPL
result appended because the probe terminates through `exit(0)`:

```text
0 1 10 13 255 65 66 67
```

The returned counts are `5`, `1`, `0`, and `2`; call order is preserved. A
separate diagnostic appears only on stderr. This demonstrates that narration
must use `eprint` when stdout is the binary artifact.

The runtime contract flushes after each call and maps write/flush failures to
`Err`. The default downstream gate does not assert broken-pipe timing because
pipe closure and buffering are OS/scheduler dependent. Applications must still
propagate a returned error and must not treat several calls as a transaction.
Unlike file-path output, stdout cannot be removed or rolled back after a later
failure.

`write_stdout` is a non-seekable process sink, not a persistent sink handle. It
does not add binary stdin, backpressure control, seeking, or explicit close.
The process owns stdout, so repository path sandbox rules do not apply to it.

The selected release executable reports `mlpl-repl 0.20.0`, build commit
`91d5216a`; the adjacent source checkout is `c3452aa1`, whose final change is
documentation-only relative to the shipped sink. `mlpl-build` still rejects
`write_stdout/1`, so standalone binary-output CLIs remain gated on compiler I/O
parity.

# Bounded incremental byte copy

`src/io/bounded_copy.mlpl` composes exact range reads with `append_bytes` to
copy a whole file or one contained range to a new sandboxed destination. It
checks the source snapshot, chunk and total-byte budgets, every read length, and
every returned append count.

Destinations follow a create-new policy: an existing path is rejected before
any output. This prevents accidental overwrite and catches source=destination,
including ordinary aliases that already resolve to an existing file. Callers
choose whether a later failure removes or retains the newly created partial
output. Cleanup failure is surfaced separately rather than claiming rollback.

Traversal is O(bytes) work and O(chunk_size) payload allocation independent of
total output. Bytes remain f64-backed, and each append opens/closes the file, so
this is a bounded-memory contract rather than a throughput claim. The
[bounded-output acceptance report](bounded-output-report.md) measures only
114,688 bytes of peak-RSS growth as exact output grows from 1 MiB to 64 MiB at
a fixed 65,536-byte chunk.

Native mlplunit covers byte-identical copies at 1, 7, 64, and 65,536, exact
subranges, empty files, tail chunks, total/range/chunk budgets, existing and
same-path destinations, filesystem/sandbox errors, and both deterministic
partial-output policies. `just bounded-copy` narrates a 7+7+3 copy and prints an
independent SHA-256 equality oracle.

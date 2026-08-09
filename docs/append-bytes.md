# Incremental file-path byte sink

The selected sw-MLPL release at commit `d3713461` provides:

```text
append_bytes(path, bytes) -> ok(count) | err(error)
```

It validates a scalar or rank-one array of integer bytes in `0..=255`, opens a
sandbox-contained file with create+append, writes the complete supplied chunk,
and closes it before returning the appended byte count. Consequently a program
can compose bounded `read_bytes(source, offset, length)` windows with bounded
transformation and `append_bytes(destination, chunk)` without retaining the
whole output.

Native mlplunit conformance verifies file creation, ordered growth, scalar and
empty append, exact counts, immediate size/read visibility, byte validation,
validation-failure preservation, sandbox traversal, missing parents, and
directory errors.

## Lifecycle and failure boundary

There is no persistent sink handle: flush/close are implicit per call. There is
also no truncate flag. A downstream writer must initialize its destination
deliberately—normally `write_bytes(path, [])` or `remove_path(path)`—before the
first append, and must choose whether to remove partial output after a later
failure.

Byte validation happens before opening, so validation errors preserve an
existing file. Operating-system failure during `write_all` can occur after a
partial write; `append_bytes` reports `Err` but does not provide transaction or
rollback semantics across or within calls. Exact all-or-old replacement remains
the separate whole-value `write_atomic` operation and is not bounded for a
large constructed output.

The sink targets sandboxed file paths only. Binary stdout, pipes, sockets,
non-seekable sinks, backpressure, and a long-lived handle remain absent. Byte
arrays remain f64-backed, so memory density is not one resident byte per file
byte, but a fixed chunk budget still bounds allocation independently of total
output size.

`mlpl-build` still rejects `append_bytes/2`; this contract is interpreter-only
until the queued compiler I/O parity work lands.

The [bounded-output acceptance report](bounded-output-report.md) exercises the
sink in 1,024 append calls producing an exact 64 MiB file and records bounded
peak-RSS growth. Binary stdout and persistent/non-seekable handles remain
separate capabilities.

The downstream [bounded-copy contract](bounded-copy.md) now supplies the
create-new, budget, count-verification, and partial-output policy around this
primitive.

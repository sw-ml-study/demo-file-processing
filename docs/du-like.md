# Confined du-like demo

`just du-like` walks the regular files beneath `fixtures/bytes` and reports
their deterministic UTF-8 lexical paths, individual logical lengths, entry
count, maximum relative depth, and total logical bytes. The fixture set makes
empty, singleton, repeated, boundary-sized, and all-byte payloads visible. An
independent host `wc -c` oracle must reproduce the 573-byte total.

This result is comparable to apparent size, not traditional allocated-block
`du` output. It does not measure filesystem blocks, directory entries,
compression, clones, holes, or metadata overhead.

MLPL validates a confined relative root, exact non-negative budgets, parallel
path/size data, strict lexical order, root membership, relative depth, each
logical size, and overflow-safe accumulation. `fs_walk` selects regular files,
resolves beneath the source sandbox, sorts lexically, and never follows
symlinks. Runtime path and metadata failures remain explicit `err(...)` values.

The current traversal API returns a materialized string list and has no
`max_entries` or `max_depth` option. Therefore the application rejects an
oversized result before issuing `file_size` calls, but discovery itself is not
bounded by those budgets. Summary work is `O(entries)` time with `O(entries)`
retained paths and sizes. A bounded traversal claim requires an upstream
iterator or traversal-time limits.

# Bounded range-reader contract

`src/io/range_reader.mlpl` is the first bounded-read foundation. It wraps the
generic native `file_size` and `read_bytes(path, offset, length)` effects in
small MLPL functions that validate budgets and carry immutable traversal state.
It is a library and conformance surface, not yet a user-visible demo, so it is
covered by mlplunit rather than added to the demo catalog.

## State and operations

`u:range_reader(path, chunk_size)` snapshots the file size and returns a record
containing path, size, current offset, and chunk budget. `u:range_next(reader)`
returns the next byte array, advanced state, and an EOF flag. Calling it at EOF
is stable and returns an empty array. `u:range_read_at(reader, offset, length)`
supports independent bounded access without changing the state.

MLPL owns input validation, range-addition overflow prevention, chunk sizing,
state transitions, short-read detection, and EOF decisions. The native runtime
owns path sandboxing, metadata, opening, seeking, allocation of the returned
ordinary f64 array, and OS errors.

## Executable boundaries

The native mlplunit suite covers chunk budgets 1, 7, 64, and 65,536; empty,
zero-length, at-EOF, beyond-EOF, and clamped reads; invalid types, signs,
fractions, and exact-domain overflow; missing paths; directories rejected when
the byte read occurs; and parent-directory sandbox traversal.

Offsets, lengths, file sizes, and budgets must be exact integers in
`0..=2^53-1`; chunk budgets must also be positive. Addition is rejected before
I/O if `offset + length` would exceed that domain. This avoids false precision
but does not make files beyond the f64 exact-offset boundary addressable.

## Allocation and limitations

Each successful call allocates at most the requested chunk as an ordinary f64
array, at least eight payload bytes per logical input byte before value and
container overhead. The state record is constant-sized and immutable. This
contract enables bounded traversal, but bounded-memory claims still require a
consumer that does not retain chunks plus measured peak-RSS evidence.

The size is a metadata snapshot. A concurrent truncation becomes a deterministic
`short_read` error; growth beyond the snapshot is ignored. Platform permission
failures remain runtime `Err` values, but a portable permission-bit fixture is
not part of the default suite because its outcome depends on process identity
and host filesystem policy.

Run the focused evidence with:

```sh
just tests tests/io
```

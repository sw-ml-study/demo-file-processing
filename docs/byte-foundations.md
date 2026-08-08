# Whole-buffer byte foundations

The first executable slice contains two small applications over deterministic
fixtures: an offset-prefixed uppercase hexdump and a 256-bin byte histogram.
Both are intentionally whole-buffer demonstrations. They establish reusable
MLPL logic before bounded streaming changes the execution model.

## Run

```sh
just generate-byte-fixtures
just hexdump
just histogram
just tests tests/bytes
just check
```

The committed fixtures are regenerated with sw-MLPL itself:

- empty byte vector;
- singleton `FF`;
- values `0..16`, crossing the default 16-byte display boundary;
- twelve repeated `07` bytes;
- every byte value `0..255` exactly once.

The default gate checks file sizes, byte sums, and the exact all-byte sequence.
No fixture is downloaded, and each is at most 256 bytes.

## Hexdump

`src/bytes/hex.mlpl` extracts high/low nibbles, maps them to uppercase ASCII,
adds fixed-width eight-digit offsets, inserts spaces/newlines, and calls
`decode_bytes` once. For the 17-byte boundary fixture:

```text
00000000  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
00000010  10
```

MLPL owns byte validation, nibble arithmetic, row boundaries, and formatting.
The generic runtime owns the initial `read_bytes` effect and final numeric-byte
to string conversion. There is no native or external hex formatter.

Logical work is O(n), but the current immutable recursive `concat` construction
repeatedly copies growing suffixes, so physical byte-copy work is O(n²) and the
call stack is O(n). Output is O(n). This is suitable for tiny teaching inputs,
not a large-file hexdump claim. A future bounded writer/string builder should
replace the construction without hiding the MLPL field logic.

## Histogram

`src/bytes/histogram.mlpl` expresses counting as an array operation:

```text
table(:eq, range(256), bytes) |> reduce_add(axis=1)
```

MLPL owns the entire count algorithm; `read_bytes` only materializes the input.
The output is always 256 counts. Logical time and the current equality matrix
are O(256n); the matrix occupies 256n f64 cells before axis reduction, in
addition to the f64-backed input and output. This makes the array-language idea
visible and deterministic, but is not the intended streaming implementation.
A later saga will compare a bounded mergeable chunk histogram and measure peak
resident memory.

The runnable demo contrasts four fixtures rather than printing only 256 ones:
all byte values once, byte 7 repeated twelve times, values 0 through 16 once,
and the empty input. Its compact view uses MLPL `compress` to report only
populated byte/count bins; the full 256-bin arrays remain the tested result.

## Validation and limits

Both APIs accept only rank-one numeric arrays of integral values `0..=255` and
return `Err` for scalars, higher-rank arrays, fractional cells, out-of-range
cells, or invalid hexdump widths. Tests cover empty, singleton, all-byte,
repeated-byte, line-boundary, and invalid cases through native mlplunit shared
assertions.

The runtime currently stores every logical byte as f64. Whole-file
`read_bytes` therefore uses at least eight payload bytes per input byte before
array/value/allocation overhead and later copies. Neither demo claims packed
storage, streaming, fusion, or bounded memory independent of file size.

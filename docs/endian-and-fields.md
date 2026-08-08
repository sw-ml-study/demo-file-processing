# Endian integers and data-described bit fields

The binary foundation now decodes and encodes unsigned integers in either byte
order and extracts MSB-first fields from a width vector. All format logic is
ordinary MLPL layered on the generic byte validator and fixed-width bit
operations; no endian, MPEG, or layout-specific runtime builtin was added.

## Run

```sh
just binary-fields
just tests tests/binary
just check
```

The narrated demo applies this MPEG audio width description:

```text
[11, 2, 2, 1, 4, 2, 1, 1, 2, 2, 1, 1, 2]
```

to the four bytes `FF FB 90 64`. It returns the description, MSB offsets, and
values as data:

```text
offsets  0 11 13 15 16 20 22 23 24 26 28 29 30
values   2047 3 1 1 9 0 0 0 1 2 0 1 0
```

That corresponds to the MPEG-1 Audio Layer III header fields in
[ISO/IEC 11172-3](https://www.iso.org/standard/22412.html): sync, version,
layer, protection, bitrate index, sample-rate index, padding, private bit,
channel mode, mode extension, copyright, original, and emphasis. The standard
is normative; the research transcript is not.

## Endian contract

`u:decode_uint(bytes, offset, width, endian)` and
`u:encode_uint(value, width, endian)` accept `"be"` or `"le"` and widths
1 through 6. Six bytes is the deliberate exact scalar limit: every u48 value
fits below f64's `2^53` exact-integer boundary. Seven- and eight-byte scalar
codecs return `Err` rather than silently round. Future 64-bit fields should use
two exact u32 words until a measured need earns a wider typed scalar.

Golden coverage includes u8, u16, u24, u32, the maximum u48 value
`281474976710655`, both byte orders, offsets, containment, values that do not
fit, fractional values, invalid endian names, zero widths, and widths above
six. Decode is O(width) time and O(1) additional numeric state. Encode is
logically O(width), with O(width²) physical copying from recursive immutable
`concat`; width is capped at six, so that cost is tightly bounded.

## Field-layout contract

`u:unpack_fields(bytes, widths)` treats the widths vector as the format
description. Widths must be positive integers and consume exactly all bits in
one through six bytes. The result is:

```text
{values, widths, offsets, total_bits}
```

Fields may cross byte boundaries; `[D6,39]` with widths `[3,5,4,4]` produces
`[6,22,3,9]`. Returning widths and offsets keeps provenance alongside values
without requiring dynamic record keys or a format-specific object type.

Packing the input is O(bytes), and extraction is logically O(fields). Current
recursive immutable concatenation makes physical value/offset copying
O(fields²), bounded here by at most 48 one-bit fields. Input remains f64-backed
and whole-buffer. The API does not claim streaming or arbitrary u64 support.

The exact-consumption rule intentionally rejects trailing reserved/padding bits;
callers must name them as fields. This makes format descriptions auditable and
prevents silent bit loss.

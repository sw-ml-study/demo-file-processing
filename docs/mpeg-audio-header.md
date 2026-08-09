# Semantic MPEG Layer III frame headers

`u:parse_mpeg_layer3_header(bytes)` turns one four-byte packed header into raw
selectors, named semantics, and derived frame geometry. MLPL owns the complete
operation: the generic runtime supplies only fixed-width bit primitives used by
the reusable data-described field extractor.

```sh
just binary-fields
just tests tests/mp3/test_mpeg_header.mlpl
```

## Normative basis and extension policy

The normative MPEG-1 source is
[ISO/IEC 11172-3:1993](https://www.iso.org/standard/22412.html), particularly
the audio-frame header syntax in 2.4.2.3. The standard covers the MPEG-1 sample
rates 32, 44.1, and 48 kHz. The public
[ITU-R BS.1115-1](https://www.itu.int/dms_pubrec/itu-r/rec/bs/R-REC-BS.1115-1-200504-W%21%21PDF-E.pdf)
summarizes the Layer III bitrate table, 1,152-sample MPEG-1 frames, free format,
padding, and byte-length calculation. MPEG-2 backward-compatible audio is
specified by
[ISO/IEC 13818-3:1998](https://www.iso.org/standard/26797.html).

MPEG-2.5 is a widely deployed but non-ISO extension. This repository labels it
`de-facto`, uses the quarter-rate sampling table 11.025/12/8 kHz and the MPEG-2
Layer III bitrate/frame rules, and tests interoperability-shaped vectors. The
official [mpg123 implementation](https://github.com/libsdl-org/mpg123) is named
as implementation evidence that MPEG 1.0/2.0/2.5 decoding is deployed; it is
not misrepresented as an ISO specification.

## Accepted Layer III model

The parser exposes sync; numeric and named version/layer; protection and
derived CRC presence; bitrate and sample-rate indices/values; padding/private;
numeric and named channel mode plus channel count; mode extension; copyright,
original, and emphasis; and derived samples and byte length per frame.

For MPEG-1 Layer III:

```text
frame_samples = 1152
frame_length  = floor(144 × bitrate_bits_per_second / sample_rate) + padding
bitrate kbit/s indices 1..14 = 32 40 48 56 64 80 96 112 128 160 192 224 256 320
```

For MPEG-2 and de-facto MPEG-2.5 Layer III:

```text
frame_samples = 576
frame_length  = floor(72 × bitrate_bits_per_second / sample_rate) + padding
bitrate kbit/s indices 1..14 = 8 16 24 32 40 48 56 64 80 96 112 128 144 160
```

Version id `01`, bitrate index 15, sample-rate index 3, and emphasis value 2
are reserved and return `Err`. This first reusable parser supports Layer III
only and returns `Err` for other layer ids rather than applying the wrong table
or formula.

Bitrate index 0 means free format. A four-byte header cannot derive its bitrate
or frame length, so the parser returns a distinct `free_bitrate` error. A later
scanner may add an explicit inference mode based on validated distance between
successive compatible sync headers; it must not silently call the value zero.

## Demonstrated contrasts and cost

The narrated demo compares `FF FB 90 64` (MPEG-1, 128 kbit/s, 44.1 kHz,
joint stereo, 1,152 samples, 417 bytes) with `FF E3 40 C0` (de-facto MPEG-2.5,
32 kbit/s, 11.025 kHz, mono, 576 samples, 208 bytes). Tests add MPEG-2 padding,
CRC protection, every channel mode, invalid byte/shape input, and every
reserved/free policy above.

Work and allocation are O(1): the input is four f64 byte cells, the field
description has 13 entries, and the returned record is fixed-sized. Current
recursive field extraction allocates small intermediate arrays, tightly bounded
by the 32-bit header. This is semantic header parsing, not frame scanning,
payload validation, audio decoding, or an external-oracle claim.

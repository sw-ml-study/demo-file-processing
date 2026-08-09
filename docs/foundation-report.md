# File-processing foundation acceptance report

## Decision

The `file-processing-foundations` saga meets its acceptance criteria. The
repository now has an mlplunit-only native test path, measured runtime/compiler
capabilities, and executable whole-buffer byte, endian/field, and PCM WAV
demonstrations. Bounded range reads also make read-only, chunked analysis
unblocked.

The former mixed streaming phase is split. `bounded-range-analysis` can start
without upstream changes. `incremental-binary-output` remains gated on a
generic bounded sink with explicit lifecycle and error semantics.

## Accepted executable evidence

| Claim | Evidence |
| --- | --- |
| Test discipline | 9 native mlplunit suites containing 27 passing tests |
| Repository gate | `just check` runs deterministic policy, fixture, catalog, capability, compiler, and native-test checks |
| Fixtures | 5 tiny raw-byte fixtures and 3 generated WAV fixtures |
| Byte I/O | Whole-file and bounded `read_bytes`, `file_size`, byte writes, EOF clamping, beyond-EOF, and zero-length reads are probed |
| Representation | Read bytes are ordinary f64 array values; exact integer behavior is bounded by 2^53 |
| Bit/endian operations | Fixed-width bit operations and exact u8 through u48 little/big-endian codecs have golden tests |
| Declarative fields | Data-described MSB-first extraction decodes fields crossing byte boundaries, including a golden MPEG header |
| Whole-buffer analysis | Hexdump formatting and a 256-bin byte histogram pass generated edge fixtures |
| PCM WAV | RIFF inspection, validation, canonical encoding/copy, malformed lengths, padding, and unsupported formats are tested |
| Process surface | Arguments, stdin, stdout/stderr, and exit behavior are interpreter-probed |
| Compiler | A narrow numeric expression compiles and has interpreter parity; unsupported and defective lowering is explicitly classified |

The catalog has 10 entries: 6 runnable demonstrations and 4 constrained
capability probes. Each entry names its MLPL, runtime, extension, or oracle
ownership rather than implying that MLPL owns work performed elsewhere.

## Rejected or deferred claims

- Range reads are not a consumable stream and do not provide bounded output.
- Byte arrays are not packed; one logical byte currently occupies an f64 slot.
- Full-domain unsigned 64-bit scalars are not exact in the current numeric type.
- WAV canonicalization does not promise byte preservation for arbitrary unknown
  chunks.
- Compiled byte/process/bit application parity is absent.
- The arithmetic compiler defect recorded at acceptance has since been fixed;
  the current capability gate requires interpreter/native parity at `72`.
- No large-file peak-RSS result or codec implementation is claimed yet.

## Complexity and allocation findings

Whole-file reads allocate ordinary numeric arrays, so payload storage is at
least eight bytes per logical byte before container overhead. Recursive array
concatenation in serializers can become quadratic. The reference histogram is
clear but scans the input once for each of 256 bins. WAV parsing and canonical
encoding create additional arrays, and output budgets constrain results only
after relevant input has already been materialized. These are acceptable for
the deliberately tiny foundation fixtures, not evidence of streaming scale.

## Smallest upstream work

No upstream change is required for bounded read-side analysis: repeatedly call
`read_bytes(path, offset, length)` using `file_size` and carry MLPL state across
ranges. Separately authorized upstream work should, in order of demonstrated
need:

1. restore the documented arithmetic build case;
2. add a generic incremental binary sink with partial-write, flush, close,
   cleanup, sandbox, and deterministic error semantics;
3. lower existing byte, bit, argument, diagnostic, and exit APIs into generated
   applications; and
4. consider packed u8 storage only after range benchmarks establish a concrete
   memory or throughput requirement.

## Recommended next saga

Archive `file-processing-foundations`, then begin `bounded-range-analysis`.
First establish a range-reader conformance helper, then prove histogram and WAV
inspection invariant at chunk sizes 1, 7, 64, and 65,536 and measure peak RSS
on a sparse input. Keep bounded copy/transformation in the separately gated
`incremental-binary-output` saga.

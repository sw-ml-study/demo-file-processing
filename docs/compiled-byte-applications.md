# Compiled byte applications

## Attempted applications

The standalone saga attempts to compile the repository's actual
self-describing [`hexdump`](../demos/bytes/hexdump.mlpl) and
[`histogram`](../demos/bytes/histogram.mlpl) demonstrations. These are not
reduced numeric toys:

- hexdump reads the 17-byte boundary fixture, validates it, renders uppercase
  hexadecimal rows, and proves that byte 16 begins offset `00000010`;
- histogram compares uniform 0–255 coverage, a repeated-byte spike, a 17-byte
  ramp, and empty input while retaining a stable 256-bin result.

Their executable MLPL behavior is already covered by native mlplunit suites,
including empty, singleton, boundary, invalid-value, fractional, scalar, and
rank-two cases. The compiler check therefore focuses on whether the same
applications can become native artifacts.

## Measured blocker ladder

`scripts/check-compiled-byte-apps` records the shipped source-loading rung and
the next independent compiler gate:

1. With `--source-dir` set to the repository root, both applications
   resolve their source-relative `include` graphs. This is positive evidence
   for upstream `compiler-source-loading` (B0), shipped 2026-08-10.
2. The selected development binary now also lowers their user function
   definitions. Both real expanded programs fail on their first `If`;
   mechanically concatenated controls reach the same boundary, showing that
   source expansion and the former workaround agree about the next gate.

Even after those front-end gates, the measured capability matrix still shows
that these programs depend on unsupported `read_bytes`, conditionals, Results,
records, text output, and—especially for hexdump—formatting/byte operations.
The histogram additionally needs table/comparison/reduction operations beyond
the compiler's narrow current numeric subset.

There is no honest interpreter/compiler parity result to report: neither
application produces a compiled artifact. The negative oracle is retained in
the default gate so newly landed support will cause an explicit failure and a
fresh positive-parity implementation, rather than leaving this report stale.

## Smallest upstream sequence

The recommended compiler order is:

1. lower conditionals and the remaining control-flow constructs;
2. provide interpreter-equivalent Result propagation and byte validation;
3. lower bounded byte input plus the array/bit/text operations exercised here;
4. provide clean stdout/stderr and exit semantics from the process-conformance
   contract; and
5. run these exact applications against all existing mlplunit fixtures and
   compare interpreter and artifact streams/statuses.

Until at least the first three items land, the next format-application step is
blocked by the same general application surface before WAV/Ogg-specific logic
is reached.

## Reproduction

```sh
just tests tests/bytes
./scripts/check-byte-demos
./scripts/check-compiled-byte-apps
just check
```

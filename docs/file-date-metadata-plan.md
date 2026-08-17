# File-date metadata demo plan

## Status and ownership

**Pure library accepted; live adapter blocked on a rebuilt interpreter.** The
reusable MLPL sorting and UTC-formatting layer is implemented and tested against
synthetic records matching the shipped primitive. The selected interpreter does
not yet expose the committed runtime call, so this repository does not simulate
live lookup with an external `stat` subprocess.

The ownership boundary is:

- `../sw-mlpl` owns confined metadata lookup, exact timestamp transport,
  platform normalization, and sandbox/symlink enforcement;
- this repository owns bounded path scanning, deterministic sorting, UTC date
  conversion and formatting, unavailable-timestamp policy, narration, and
  mlplunit acceptance; and
- `../demo-extensions` consumes the same primitive for its model picker rather
  than introducing an extension-specific filesystem API.

Directory enumeration is not implied by metadata lookup. The first demo will
accept an explicit bounded list of paths through arguments or a fixture
manifest. A future directory-listing request must be measured and contracted
separately if a consumer needs discovery rather than metadata for known paths.

## Smallest upstream contract

The active upstream saga proposes the general record:

```text
file_metadata(path) -> Result<{
  kind: String,
  size: Number,
  modified_unix_ms: Number
}, Error>
```

`modified_unix_ms` is an integral UTC Unix-millisecond value: elapsed milliseconds
from `1970-01-01T00:00:00Z`, not local time, formatted text, seconds, or a
floating fractional approximation. Values must remain inside MLPL's exact
integer domain; an unrepresentable platform value returns an explicit error
instead of rounding. Dates before the epoch must either be supported as exact
negative integers consistently on every supported platform or rejected with a
documented, stable error kind.

The operation must preserve the existing file-I/O confinement contract:

- repository/source-root sandbox checks happen before host metadata access;
- traversal outside the root is rejected;
- symlinks follow the same policy as `file_size` and `read_bytes`, including
  rejection of escapes;
- missing, denied, unsupported, unrepresentable, and timestamp-unavailable
  cases return distinguishable stable `Err` records; and
- interpreter and compiled implementations eventually share these semantics.

No wall-clock read, timezone database, locale formatting, directory walker, or
model-specific behavior belongs in this primitive.

## Planned MLPL application

The self-describing `file-date-index` demo now:

1. accept a bounded explicit path list and maximum-entry budget;
2. request modification metadata once per path and retain either the exact
   millisecond value or a structured unavailable result;
3. sort available entries by descending timestamp, then normalized path as a
   deterministic tie-breaker;
4. place unavailable entries after available entries, sorted by normalized
   path and annotated with their error kind;
5. convert exact milliseconds to a proleptic-Gregorian UTC representation in
   pure MLPL and print stable ISO-8601 text with three fractional digits; and
6. explain the input order, sort policy, UTC interpretation, unavailable
   policy, runtime-versus-MLPL ownership, and final rows.

The demo will show intentionally out-of-order old/new/equal timestamps and an
unavailable entry. Output must be interesting evidence—not a bare `PASS`—while
the test suite owns assertions.

Logical work is `O(n^2)` for bounded insertion sorting and `O(n)` retained index
storage, intentionally matching small picker menus. It is not a recursive
directory walk or a streaming claim.

## Acceptance tests

All executable MLPL coverage will use native mlplunit registration. Pure tests
will be written before the runner and will cover:

- ascending input becoming descending timestamp order;
- deterministic path ordering for equal millisecond values;
- empty and singleton inputs;
- exact epoch, pre-epoch policy, leap days, century rules, day boundaries, and
  millisecond zero-padding in UTC formatting;
- timestamps near the accepted exact-integer boundary without rounding;
- missing, denied, unsupported, unavailable, sandbox-escape, and symlink cases;
- a maximum-entry budget checked before metadata collection; and
- stable placement and narration of unavailable entries.

An integration harness will create temporary files with portable whole-second
timestamps and compare returned Unix milliseconds against an independent host
oracle on each supported platform. Millisecond-resolution cases run only where
the filesystem reports that resolution and must be explicitly reported rather
than silently rounded. macOS and Linux must agree on normalized values, error
kinds, tie-breaking, and rendered UTC output.

Compiled parity is a later acceptance gate: once generic application lowering
and metadata lowering exist, the same fixtures must match interpreter stdout,
stderr, status, values, and errors in a source-free artifact.

## Resume trigger and next steps

The pure timestamp sort/format library, native mlplunit suite, narrated demo,
output oracle, and catalog entry are complete. Resume the thin live adapter only
after an adjacent development `mlpl-repl` exposes the contract above. First add
a focused capability probe for exactness, errors, confinement, symlinks, and
platform units, then replace synthetic acquisition with real bounded paths
while retaining the same pure library and output policy.

Until then, the smallest upstream action is to ship the confined metadata
primitive and provide a rebuilt adjacent development interpreter. No change to
this repository can produce honest runtime timestamp evidence before that.

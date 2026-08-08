# Sparse-file peak-memory evidence

The opt-in acceptance harness creates four deterministic sparse artifacts and
runs each consumer in a fresh process under the platform `time` utility:

```sh
just sparse-memory-evidence
```

| Consumer | Small artifact | Large artifact | Fixed read budget |
| --- | ---: | ---: | ---: |
| bounded histogram | 65,536 bytes | 1,048,576 bytes | 256 bytes |
| bounded WAV inspection | 1,048,576 payload bytes | 67,108,864 payload bytes | 7 bytes |

The harness enforces a 33,554,432-byte peak-RSS ceiling for every process and
an 8,388,608-byte maximum RSS increase between each small/large pair. The large
WAV payload is twice the RSS ceiling. The large histogram is also larger than
its roughly 0.5 MiB equality-matrix numeric payload at the fixed chunk budget;
it is kept to 1 MiB because the deliberately pedagogical O(256n) algorithm is
slow, not because it materializes the file.

## Recorded result

Measured on 2026-08-08 on arm64 macOS 26.5 with `mlpl-repl 0.20.0`:

| Run | Peak RSS |
| --- | ---: |
| histogram, 65,536 bytes | 20,316,160 bytes |
| histogram, 1,048,576 bytes | 21,397,504 bytes |
| WAV, 1,048,576-byte payload | 10,043,392 bytes |
| WAV, 67,108,864-byte payload | 10,190,848 bytes |

The enforced non-negative growth metric was 1,081,344 bytes for histogram and
147,456 bytes for WAV. An earlier run measured zero growth for both pairs,
showing the expected process/allocator variability. Both runs satisfy the
configured 8 MiB growth and 32 MiB absolute ceilings and support the claim that
retained memory depends on chunk plus fixed analysis state rather than total
file size. These observations are not universal platform maxima; the
executable ceilings, rather than exact point values, are the repeatable
acceptance contract.

## Method and boundaries

On macOS the harness parses bytes from `/usr/bin/time -l`; on Linux it converts
KiB from `/usr/bin/time -v`. Other operating systems exit 77. Restricted macOS
sandboxes may deny the kernel metrics query, in which case the harness fails
with an instruction to run where the metric is available. Sparse files live in
an ignored temporary directory and are removed on exit.

The histogram reads every logical byte and checks that only bin zero is
populated. Its high CPU cost is visible: it creates a 256-by-chunk equality
matrix for every range. The WAV inspector reads headers only and verifies its
data offset/length against file metadata; it does not assert sample contents.
Thus the two measurements cover bounded sequential reduction and bounded
payload-skipping inspection without confusing sparse allocation with decoded
audio validation.

Platform `time` is an external measurement oracle. MLPL owns traversal,
histogram reduction, RIFF parsing, and invariants; the generic runtime owns
bounded reads and metadata; the shell owns sparse fixture construction and RSS
ceiling enforcement.

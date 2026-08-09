# Incremental binary output

## 1. append_bytes sink conformance

Probe and stabilize sandboxed file-path append semantics, byte validation, empty writes, counts, missing parents, path errors, existing-file behavior, failure preservation, and current interpreter/compiler boundaries.

## 2. bounded byte copy

Implement read-range to append loops with explicit chunk and total-byte budgets, byte-identical/hash evidence, malformed paths, cleanup policy, chunk invariance, and bounded-memory structure.

## 3. bounded WAV copy and transform

Use accepted WAV range descriptors to copy canonically and perform one visible PCM transformation through bounded reads and append writes, with semantic/byte oracles and narrated output.

## 4. ID3 stripping and MPEG extraction

Use accepted ID3 audio descriptors and MPEG scanning to write bounded stripped MP3 and raw accepted-frame outputs with byte preservation and malformed-input behavior.

## 5. Ogg page copy and rewrite

Use accepted Ogg page descriptors to copy pages and perform one bounded header/page rewrite with recomputed CRC, sequence/integrity verification, and oracle comparison.

## 6. bounded-output acceptance report

Measure growing-output peak RSS, run the full gate, stabilize file-path sink/copy/rewrite APIs, reconcile documentation and capability contracts, and publish remaining stdout/compiler/codec blockers.
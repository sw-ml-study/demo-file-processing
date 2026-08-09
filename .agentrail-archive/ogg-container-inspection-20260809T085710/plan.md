# Ogg container inspection

## 1. Bounded Ogg page model

Parse Ogg capture patterns, version, header flags, split-word granule position, serial/sequence/checksum fields, lacing values, body extents, and strict page/segment/body budgets through bounded range reads.

## 2. Cross-page packet reconstruction

Model packet boundaries and continuation semantics across pages and arbitrary read chunks with bounded packet budgets and deterministic malformed-stream errors.

## 3. Ogg CRC verification

Implement the Ogg CRC-32 polynomial visibly in MLPL, add golden vectors, verify stored page checksums without format-specific native parsing, and document complexity and current allocation behavior.

## 4. Fixtures, oracle, and narrated demos

Add tiny generated valid/malformed Ogg fixtures, chunk-invariant mlplunit evidence, a pinned opt-in oracle, and self-describing page, packet, and CRC demonstrations that explain inputs, ownership, outputs, and interpretation.

## 5. Read-only Ogg acceptance report

Run the full gate; stabilize page, packet, CRC, and rewrite-descriptor APIs; reconcile README, catalog, plans, sagas, capabilities, and upstream contracts; publish limitations, blockers, and next work.
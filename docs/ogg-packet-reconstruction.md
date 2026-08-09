# Bounded Ogg packet reconstruction

`src/ogg/packets.mlpl` walks a bounded range as one logical Ogg stream and folds
lacing values into packet boundaries without reading or retaining page bodies.
It enforces BOS/EOS placement, a stable stream serial, consecutive page
sequence numbers (including u32 wrap), and exact agreement between the page
continued flag and unfinished packet state.

The result contains fixed-size page/packet/segment/body totals, continuation
and spanning-packet counts, zero-length packet count, and min/max/average packet
sizes. It intentionally does not return an unbounded packet list. A later
payload consumer can traverse the same validated pages and reread bounded body
ranges when an output or codec interface exists.

Explicit stream-byte, page-count, per-page extent/segment/body, packet-count,
and packet-byte budgets cap all work. Packet traversal is O(pages + segments)
time and O(max_segments) transient allocation inherited from the page lacing
table; retained aggregate state is fixed size. Multiplexed serials are an
explicit error for this one-logical-stream API rather than silently combining
unrelated packets.

Native mlplunit evidence includes a 265-byte packet continued across pages,
ordinary and zero-length packets, every required chunk budget, sequence and
serial faults, missing/unexpected continuation, BOS/EOS faults, truncated
ranges, unfinished packets, and each work budget.

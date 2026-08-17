# Bounded wc-like demo

`just wc-like` demonstrates a small Unix-style counter whose traversal and
state transitions remain visible in MLPL. It reports physical bytes, LF
terminators, logical lines, and ASCII-delimited words for input containing
spaces, a tab, CRLF, LF, an unterminated final line, and UTF-8 text. Separate
empty and UTF-8 cases make the output useful rather than a pass marker.

The contract intentionally distinguishes related meanings:

- `bytes` is the file byte length, not Unicode characters;
- `lines` counts LF bytes, matching traditional `wc -l` behavior;
- `logical_lines` adds one when non-empty input does not end in LF;
- CRLF contributes one LF-terminated line; and
- words are maximal runs outside ASCII TAB, LF, VT, FF, CR, and SPACE.

The MLPL library preflights `file_size <= max_bytes`, requests at most
`chunk_size` bytes at a time, validates exact read lengths, and carries only
counts, the prior word-boundary bit, the last byte, and the current chunk.
Tests prove identical semantic counts for 1-, 2-, 7-, and 65,536-byte chunks,
including boundaries inside words and CRLF. Logical complexity is `O(n)` and
live payload is `O(chunk_size)`; this is a bounded range-reader application,
not a persistent stream handle.

Native mlplunit covers empty input, whitespace-only input, UTF-8 byte versus
word behavior, the unterminated-final-line policy, chunk invariance, invalid
logical bytes, invalid chunk sizes, and rejection when the file exceeds its
budget before reading.

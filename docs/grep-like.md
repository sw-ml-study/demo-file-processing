# Bounded grep-like demo

`just grep-like` searches a generated file for a non-empty literal byte pattern
and reports matching one-based logical line numbers. The narrated input includes
a match at line start, a long matching line split across range reads, a
non-match, and a matching unterminated final line. Separate CRLF and malformed
UTF-8 byte cases expose the precise policy.

This is intentionally byte-oriented rather than regex- or Unicode-oriented:

- LF terminates a line; CR remains ordinary searchable line content;
- a non-empty unterminated final line is evaluated;
- the pattern is a non-empty logical-byte vector;
- malformed UTF-8 is accepted and searched without decoding; and
- one line number is returned per matching line, regardless of occurrences.

Before reading, MLPL requires `file_size <= max_bytes`. Each read is at most
`chunk_size`; the current line is capped by `max_line_bytes`; the numeric result
list is capped by `max_matches`; and short reads fail. Lines and pattern matches
may cross any chunk boundary because MLPL carries the bounded current line.

Worst-case matching time is `O(file_bytes × pattern_bytes)`. Live state is
`O(chunk_size + max_line_bytes + max_matches)`, not total file size. Native
mlplunit covers line numbers, CRLF/final-line behavior, malformed UTF-8 bytes,
1/7/65,536-byte chunk invariance, empty/invalid patterns, and all three budgets.

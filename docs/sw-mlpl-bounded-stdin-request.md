# sw-MLPL request: bounded incremental stdin

Status: **delivered upstream and accepted downstream.** Upstream commit
`e7240dba` supplies interpreter/compiler `read_stdin_chunk`; the compiled wc
consumer passes cross-read, budget/error, host-oracle, and 1 MiB/64 MiB RSS
acceptance. This document remains the contract record.

## Downstream requirement

Standalone Unix-style filters must process pipes with memory bounded by a
caller-selected chunk size. The shipped `read_stdin()` and
`read_stdin_lines()` block until EOF and materialize the complete stream. A
program that subsequently slices that value is still `O(total_input)` memory
and does not satisfy this requirement.

The smallest general upstream surface is:

```text
read_stdin_chunk(max_bytes)
  -> ok({bytes: Array, eof: 0|1})
  -> err({kind, message})
```

`bytes` must contain raw logical byte values, not decoded text. One call must
return no more than `max_bytes`. UTF-8 sequences may split across chunks because
byte-oriented consumers must not depend on text decoding.

## Required semantics

- `max_bytes` is an exact positive integer; zero, negative, fractional,
  non-scalar, and unsafe values return `err(...)` without consuming stdin.
- A call blocks until at least one byte, EOF, or an I/O error. Short non-empty
  chunks are permitted.
- EOF is explicit. The terminal result is `{bytes: [], eof: 1}`; repeated calls
  after EOF remain terminal and do not block.
- A non-empty final chunk may set `eof: 0`; the following empty call may report
  EOF. Consumers must support either this simple contract consistently.
- Stdin is a single forward-only process source: no seek, rewind, or second
  independent consumer is implied.
- Interactive-terminal refusal remains consistent with `read_stdin()`.
- Read errors are Results, produce useful stderr at an application boundary,
  and lead to a nonzero compiled exit status when unhandled.
- Interpreter and compile-to-Rust behavior ship together with the same byte,
  EOF, validation, error, and TTY semantics.

The name is negotiable; the bounded byte/EOF behavior is not. A handle-based
`stdin_open`/`read_next` design is acceptable if it provides the same single-
pass guarantees without exposing an unbounded hidden buffer.

## Downstream acceptance

The first consumer will be the compiled wc-style filter. It will:

1. read caller-sized chunks in a loop;
2. carry LF, ASCII-word-boundary, and previous-byte state across chunks;
3. enforce an independent exact `max_total_bytes` budget;
4. cover chunk sizes 1, 7, 64, and 65,536;
5. cover empty input, CRLF, unterminated final text, malformed UTF-8 bytes,
   delimiters split at boundaries, short reads, and budget rejection;
6. compare counts and exit status with host `wc -l -w -c`; and
7. measure peak RSS for 1 MiB and 64 MiB inputs before claiming
   `O(chunk_size)` live memory.

Acceptance also requires a source-free compiled artifact with no parser/REPL
runtime dependency. `write_stdout`/text diagnostics must preserve broken-pipe
and other sink errors rather than silently succeeding.

## Accepted evidence

`demos/files/wc_stdin.mlpl` is now the accepted first consumer. It calls
`read_stdin_chunk(1)` directly, preserves byte-oriented word state across every
read, and does not tokenize or slice a whole-input `read_stdin()` value.

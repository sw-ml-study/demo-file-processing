# Bounded binary stdout applications

`bounded_stdout_range` and `bounded_stdout_file` compose accepted seekable range
reads with `write_stdout`. They validate exact offsets, contained extents,
positive chunk size, and a total-byte budget before the first write. Every read
length and returned stdout count must match. Retained payload state is
O(`chunk_size`) and no output vector or chunk history is accumulated.

Stdout is irreversible: unlike create-new file output, a later read/write error
cannot remove bytes already consumed by a pipe. The API returns the failure and
does not claim a transaction. Applications should validate format descriptors
and integrity before beginning output whenever possible.

Three demonstrations keep stdout exclusively binary and put all explanation on
stderr:

| Recipe | Binary stdout | Interesting interpretation |
| --- | --- | --- |
| `just stdout-bytes` | bytes `0..16` | seven-byte budget produces `7 + 7 + 3` |
| `just stdout-wav` | complete 48-byte PCM WAV | three unsigned samples plus odd pad remain byte-identical |
| `just stdout-ogg` | first 283-byte Ogg page | CRC is verified before output; lacing 255 leaves a continued packet |

The gate captures each stream, compares raw/WAV bytes exactly, compares the Ogg
page with its source descriptor range, and independently reparses and verifies
the captured Ogg checksum. Demos call `exit(0)` after writing so the interpreter
does not print a final value into stdout.

For interactive use, redirect stdout while leaving narration visible:

```sh
just stdout-wav > output.wav
just stdout-ogg > first-page.ogg
```

The adjacent development compiler lowers `args` and `write_stdout`, but its
generated wrapper appends a textual result line; range reads and format bit
operations also remain unsupported. These are therefore pipeline-capable
interpreter scripts rather than clean standalone binary CLIs. Binary
stdin/source handles and codec state remain separate. The
[stdout acceptance report](stdout-report.md) measures exact captured output at
1 MiB and 64 MiB under fixed RSS ceilings.

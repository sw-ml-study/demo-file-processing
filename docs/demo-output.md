# Demonstration output contract

User-facing `just` demonstrations are narrated executable examples, not test
commands with friendlier names. Each output answers five questions:

1. What practical file-processing idea is being demonstrated?
2. What deterministic input makes the behavior interesting?
3. Which substantive work is performed in MLPL?
4. Which generic effects are supplied by the native runtime or an external
   measurement oracle?
5. What does the output mean, including the boundary or contrast it proves?

Machine-checkable invariants still make each demo fail on a wrong result, and
the repository gate checks stable narrative/result landmarks. The final `Ok`
value is diagnostic structure, not the explanation. Tests, audits, fixture
generation, and tool-path recipes remain intentionally terse and are not
presented as demonstrations.

## Current narrated demonstrations

| Recipe | Interesting input or contrast | Interpretation emphasized |
| --- | --- | --- |
| `just hexdump` | 17 sequential bytes across a 16-byte row | why offset `00000010` begins a second row |
| `just histogram` | uniform, concentrated, ramp, and empty distributions | how the same 256-bin shape represents different data |
| `just bounded-histogram` | every byte value across 37 seven-byte ranges | why chunk boundaries do not change counts |
| `just bounded-copy` | 17 bytes emitted as 7+7+3 with matching SHA-256 | how bounded reads and appends produce exact file output |
| `just binary-fields` | contrasting MPEG-1 and de-facto MPEG-2.5 headers | how selectors become rates, samples, and byte lengths |
| `just mp3-scan` | 128/160/128 kbit/s frames plus a separate damaged gap | why bitrate changes imply VBR and how synchronization is reacquired |
| `just id3-inspect` | selected text, unknown payload, padding, audio range, and truncation | why metadata is materialized but audio remains a descriptor |
| `just ogg-pages` | BOS page, 255-byte lace, continued page, and unset granule | how lacing becomes body/next-page descriptors |
| `just ogg-packets` | spanning, ordinary, zero, and malformed-continuation packets | how packet state crosses pages without payload retention |
| `just ogg-crc` | checksum-valid page versus one changed body byte | why structural parsing and integrity verification are separate |
| `just wav-inspect-copy` | three unsigned 8-bit samples plus odd padding | why canonical parse/encode is byte-identical |
| `just wav-range-inspect` | odd padded JUNK chunk before one sample | how metadata inspection skips payloads and locates audio |
| `just wav-bounded-output` | canonical copy plus `[0, 127, 255]` → `[255, 128, 0]` | how fixed headers and bounded sample chunks produce real WAV files |
| `just sparse-memory-evidence` | 16× histogram and 64× WAV size contrasts | how to read RSS ceilings and distinguish MLPL work from the platform oracle |
| `just mp3-oracle` | checksum/version-pinned decodable tone | why structural Xing frames differ from decoded packets and presentation duration |
| `just ogg-oracle` | checksum/version-pinned Ogg/Opus tone | why Opus header packets differ from decoded audio packet counts |

The sparse recipe is opt-in because the O(256n) teaching histogram is slow and
the platform must expose peak-RSS metrics. Its MLPL applications narrate their
own algorithms; the shell additionally explains the cross-process measurement
method and acceptance thresholds. The MP3 oracle is opt-in because it requires
exactly ffprobe 8.1.2; default MLPL behavior remains independent of that tool.
The same rule applies to the Ogg/Opus oracle.

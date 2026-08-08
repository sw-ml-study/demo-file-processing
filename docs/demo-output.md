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
| `just binary-fields` | packed MPEG-1 Layer III header | how raw cross-byte fields become audio metadata |
| `just wav-inspect-copy` | three unsigned 8-bit samples plus odd padding | why canonical parse/encode is byte-identical |
| `just wav-range-inspect` | odd padded JUNK chunk before one sample | how metadata inspection skips payloads and locates audio |
| `just sparse-memory-evidence` | 16× histogram and 64× WAV size contrasts | how to read RSS ceilings and distinguish MLPL work from the platform oracle |

The sparse recipe is opt-in because the O(256n) teaching histogram is slow and
the platform must expose peak-RSS metrics. Its MLPL applications narrate their
own algorithms; the shell additionally explains the cross-process measurement
method and acceptance thresholds.

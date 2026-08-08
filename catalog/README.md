# Demo catalog

`demos.tsv` is the validated inventory of runnable, constrained, gated, and
external file-processing demonstrations. Its nine tab-separated columns are:

| Column | Contract |
|---|---|
| `id` | Stable lowercase identifier |
| `path` | Repository-relative `.mlpl` path under `demos/` or `probes/` |
| `format` | File format or byte protocol |
| `operation` | User-visible inspection or transformation |
| `implementation_layer` | `mlpl`, `mlpl-native`, `codec-extension`, or `external` |
| `memory_bound` | `whole-file`, `chunk-bounded`, or `not-applicable` |
| `default_gate` | Whether `just check` executes it |
| `required_features` | Comma-separated capabilities or `current` |
| `status` | `runnable`, `constrained`, `gated`, or `external` |

Runnable, constrained, and external rows must reference an existing file.
Gated rows describe planned locations and cannot run in the default gate.
Whole-file reads remain `whole-file` even if later processing uses chunks.

Implementation ownership is explicit: `mlpl` performs substantive work in the
language; `mlpl-native` uses only a generic runtime effect/representation;
`codec-extension` delegates a named mature codec kernel while MLPL owns the
pipeline; and `external` is a named oracle, baseline, or fallback.

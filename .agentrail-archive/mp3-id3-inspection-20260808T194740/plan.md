# MP3 and ID3 inspection

## 1. MPEG audio frame-header model

Turn the existing golden bit-field example into a reusable semantic MPEG audio
header parser. Cover MPEG versions, layers, bitrate/sample-rate tables, channel
modes, padding, frame-length formulas, reserved combinations, and free bitrate
policy with authoritative references and mlplunit vectors. Keep format logic in
MLPL and use no native MPEG parser.

## 2. Bounded resynchronizing frame scanner

Scan seekable MP3 files through accepted range/window contracts, carrying only
bounded state across arbitrary chunk splits. Define deterministic sync recovery,
false-positive rejection, truncation, scan budgets, and constant/variable
bitrate statistics. Compare chunk sizes 1, 7, 64, and 65,536.

## 3. Bounded ID3v2 inspection

Parse supported ID3v2 headers and frames through bounded reads with synchsafe
sizes, version/flag validation, text decoding policy, padding, extended-header
handling where supported, and strict byte/frame/text budgets. Emit metadata and
audio range descriptors without stripping, copying, or writing.

## 4. Fixtures, oracle, and narrated demos

Add tiny generated or clearly redistributable MP3/ID3 fixtures, malformed cases,
and an explicit pinned oracle for opt-in comparison. Prove chunk invariance and
scanner/tag statistics through mlplunit. Add self-describing frame, scan, and
ID3 demonstrations that explain input, MLPL/native/oracle ownership, operation,
and interpretation.

## 5. Read-only MP3/ID3 acceptance report

Run `just check`, document complexity, allocation, measured memory where needed,
supported/unsupported variants, stabilized read-only APIs, and output
descriptors for the later incremental-output saga. Reconcile README, catalog,
plans, saga queue, and upstream contracts; report blockers and the next
highest-value unblocked saga.

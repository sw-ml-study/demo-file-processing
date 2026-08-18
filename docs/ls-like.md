# Confined ls-like metadata demo

`just ls-like` performs a non-recursive confined walk of `fixtures/bytes`, then
uses `file_metadata` for each regular file. It prints deterministic UTF-8
lexical names, portable `file` kinds, logical sizes, exact Unix-millisecond
modification values, and UTC ISO-8601 millisecond text.

The executable checker fixes names/kinds/sizes, accepts platform-dependent live
timestamps only when they match the host `stat` value at Unix-second precision,
and checks the MLPL millisecond value's UTC shape. It supports macOS `stat -f`
and Linux `stat -c`. A temporary confined sandbox separately proves a normal
file succeeds while missing paths and symlinks escaping the sandbox fail.

A synthetic section makes policies that ordinary checkout metadata cannot
reliably produce deterministic: two equal timestamps sort by UTF-8 path, the
rows exercise `file`, `dir`, and `other`, and an unavailable timestamp sorts
last and displays `timestamp unavailable` rather than epoch zero.

Acquisition and validation are `O(entries)` and retain parallel metadata
vectors. Optional newest-first ordering reuses the date-index library's bounded
insertion sort, which is `O(entries²)` time and `O(entries)` storage and is
intended for small interactive listings. `fs_walk` still materializes its path
list, so no bounded-discovery claim is made.

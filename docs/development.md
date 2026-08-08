# Development workflow

## Validation

Use the thin root recipes:

```sh
just audit
just tests
just tap
just list-tests
just check
```

`just check` is the required pre-commit gate. It checks shell syntax and
permissions, licensing, local Markdown links, tiny-fixture policy, catalog
schema, Agentrail/direct-main policy, mlplunit adoption, expected validation
failures, native MLPL tests, and Git whitespace. Recipes delegate to portable
scripts so `./scripts/check` remains usable without `just`.

Tiny deterministic generated or redistributable fixtures belong under
`fixtures/`. They must be regular files no larger than 1 MiB. Downloaded media
and generated outputs belong under ignored `media/`, `artifacts/`, or `out/`
directories and never enter the default gate.

## Tool selection

The repository never installs or replaces sw-MLPL or mlplunit. Selection order
is:

1. absolute `MLPL`, `MLPLUNIT`, or `MLPL_BUILD` override;
2. `mlplunit` on `PATH` for the test runner;
3. documented adjacent development checkout;
4. for sw-MLPL only, release then debug adjacent builds;
5. otherwise a clear failure with setup instructions.

```sh
MLPL=/absolute/path/to/mlpl-repl just mlpl-path
MLPLUNIT=/absolute/path/to/mlplunit just mlplunit-path
MLPL_BUILD=/absolute/path/to/mlpl-build just mlpl-build-path
```

## Native mlplunit contract

All executable MLPL tests live beneath `tests/`, match `test_*.mlpl`, register
one or more native `@test` functions, call mlplunit shared `u:assert_*`
functions, and finish with `u:run_registered_tests()`. The repository does not
copy assertion/lifecycle helpers or use direct interpreter scripts as tests.

The runner supports mlplunit's human, TAP, listing, path, and filter behavior:

```sh
just tests
just tap
just list-tests
just tests tests/foundation
just tests --pattern '*repository_contract*.mlpl' tests
```

Standalone demos may be self-checking for readers, but their behavior also
requires focused native mlplunit coverage.

## Capability probes

`just capabilities` validates interpreter process I/O and the current compiler
boundary. Native language assertions for bytes, ranges, bits, integer limits,
and arguments live in mlplunit suites under `tests/capabilities/`. See the
[measured baseline](capabilities.md) and
[upstream contracts](upstream-contract.md) for claim limits and blockers.

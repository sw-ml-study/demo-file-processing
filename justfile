set shell := ["sh", "-cu"]

# Show available repository tasks.
default:
    @just --list

# Run structural, policy, catalog, fixture, and documentation audits.
audit:
    ./scripts/audit

# Run all native mlplunit tests; extra arguments select paths or filters.
tests *args:
    ./scripts/run-tests {{args}}

# Emit native test results as TAP.
tap *args:
    ./scripts/run-tests --format tap {{args}}

# List tests discovered by mlplunit without executing them.
list-tests:
    ./scripts/run-tests --list

# Print selected tools without installing or replacing them.
mlpl-path:
    ./scripts/select-mlpl

mlplunit-path:
    ./scripts/select-mlplunit

# Run the complete pre-commit gate.
check:
    ./scripts/check

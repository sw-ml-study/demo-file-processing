# Saga: compiler-gate-refresh

Refresh downstream evidence after upstream compiler source loading shipped, without modifying sw-mlpl.

## Steps
1. compiler-source-loading-evidence -- Update focused detectors and documentation to accept include expansion with an explicit repository source root, identify FnDef as the current earliest blocker, run the full gate, and publish the evidence.
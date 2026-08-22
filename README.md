# Cerebellar Preparatory Dynamics Model

`v2-no-plant` is the active development branch.

The previous plant-based Hennequin ISN implementation is historical and remains recoverable from:

- branch `v1-hennequin-isn`
- annotated tag `pre-cleanup-plant-isn`
- commit `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`

This branch intentionally removes the biomechanical plant, plant-specific workflows, and their generated artifacts. It retains only a minimal project scaffold, the official fixed Hennequin/why-prep-2 recurrent matrix with provenance, and a generic GPU-selection utility.

The next planned step is implementation of a simplified no-plant cortical-cerebellar model. No new model has yet been specified, implemented, simulated, or trained on this branch.

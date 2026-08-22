# Cerebellar Preparatory Dynamics Model

`v2-no-plant` is the active development branch.

The previous plant-based Hennequin ISN implementation is historical and remains recoverable from:

- branch `v1-hennequin-isn`
- annotated tag `pre-cleanup-plant-isn`
- commit `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`

This branch intentionally removes the biomechanical plant and uses a linear cortical-rate readout to two-dimensional velocity followed only by numerical position accumulation. The exact official Hennequin/why-prep-2 recurrent matrix remains fixed and hash-verified.

The intact no-plant V2 architecture is implemented with persistent one-hot target input, a target-independent go pulse, and a target-only relaxing 5-D cerebellar pathway. Static, forward, gradient, and two-update smoke validation passed. The required 20-update RTX 6000 Ada benchmark predicted approximately 150 minutes per 1,000 updates, so the 60-minute runtime gate stopped the workflow before Stage A. There is no trained or accepted intact V2 baseline. No cerebellar removal or lesion experiment is implemented.

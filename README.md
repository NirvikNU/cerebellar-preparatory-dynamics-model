# Cerebellar Preparatory Dynamics Model

`v2-no-plant` is the active development branch.

The previous plant-based Hennequin ISN implementation is historical and remains recoverable from:

- branch `v1-hennequin-isn`
- annotated tag `pre-cleanup-plant-isn`
- commit `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`

This branch intentionally removes the biomechanical plant and uses a linear cortical-rate readout to two-dimensional velocity followed only by numerical position accumulation. The exact official Hennequin/why-prep-2 recurrent matrix remains fixed and hash-verified.

The intact no-plant V2 architecture is implemented with persistent one-hot target input, a target-independent go pulse, and a target-only relaxing 5-D cerebellar pathway. Static and smoke validation must pass before the implementation checkpoint; bounded intact training and acceptance evaluation follow. No cerebellar removal or lesion experiment is implemented.

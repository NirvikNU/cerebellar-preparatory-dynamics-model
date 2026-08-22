# Cerebellar Preparatory Dynamics Model

`v2-no-plant` is the active development branch.

The previous plant-based Hennequin ISN implementation is historical and remains recoverable from:

- branch `v1-hennequin-isn`
- annotated tag `pre-cleanup-plant-isn`
- commit `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`

This branch intentionally removes the biomechanical plant and uses a linear cortical-rate readout to two-dimensional velocity followed only by numerical position accumulation. The exact official Hennequin/why-prep-2 recurrent matrix remains fixed and hash-verified.

The intact no-plant V2 architecture is implemented with persistent one-hot target input, a target-independent go pulse, and a target-only relaxing 5-D cerebellar pathway. Static, forward, gradient, and two-update smoke validation passed. A technical runtime audit found that the original benchmark changed accelerated-function output arity and timed MATLAB's one-time trace optimization inside the update loop. The corrected fixed-signature RTX 6000 Ada path runs at approximately 2.79 seconds/update after warm-up. Stage A has not started, so there is no trained or accepted intact V2 baseline. No cerebellar removal or lesion experiment is implemented.

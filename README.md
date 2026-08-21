# Cerebellar Preparatory Dynamics Model

**Status: under development.**

This repository contains a computational model examining how a low-dimensional feedforward cerebellar input shapes motor-cortical preparatory dynamics and their transformation into torque-driven, two-joint reaching movements.

The current milestone contains only the finalized intact V1 architecture: a 100-unit continuous-time cortical rate RNN, an unsupervised 5-D target/time-conditioned cerebellar generator with a fixed random projection into cortex, and a fixed horizontal two-link arm. Cerebellar lesions, blocks, scaling experiments, and V2 state-dependent feedback are not implemented.

The saved checkpoint was retrained for 5,000 balanced-minibatch Adam updates with the documented plasticity hierarchy. It is retained for diagnosis but is **not yet an accepted intact baseline**: the configured endpoint, terminal-speed, and pre-go-stationarity criteria did not pass. See `results/intact_numerical_summary.mat`, `IMPLEMENTATION_NOTES.md`, and the latest Notion Codex Development Log entry before using it in scientific comparisons.

Run `run_all.m` from a clean MATLAB session to repeat the full training, deterministic/noisy evaluation, delay analysis, and `.fig`/`.png` diagnostic workflow. MATLAB Deep Learning Toolbox and a CUDA-capable GPU are strongly recommended for the multi-thousand-update custom training loop.

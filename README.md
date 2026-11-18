# Cerebellar contributions to cortical preparatory dynamics

Computational model accompanying the manuscript *Cerebellar shaping of motor cortical preparatory states underlies predictive control of movement*.

The model combines target-dependent state setting and corrective control during motor preparation in ten recurrent networks of 200 rectified-linear units. Removing both components exposes the alternative cortical preparatory states, while the movement generator, motor readout and two-link arm remain fixed. The repository provides the model implementation, accepted networks, numerical source tables and editable publication figures.

## Publication figures

| Panels | Analysis |
|---|---|
| Fig. 6a,b | Preparatory dimensionality and alignment across corrective-control effort penalties |
| Fig. 6c | Hand-drawn functional-model schematic |
| Fig. 6d–f | Example reaching trajectories, hand speeds and peak-speed positions |
| Fig. 6g | Control neural prediction across initial-state and temporal noise |
| Fig. 6h | Control and Block neural prediction across temporal noise |
| Extended Data Fig. 5a–c | Shared preparatory-geometry calibration and experimental/model comparisons |

Editable FIGs, PNGs and both assemblies are in [publication figures](plots/paper_ready/final_v3/production). Full-precision values are in [source tables](data/paper_ready/final_v3/tables). [Figure legends](docs/paper_ready/final_v3/production/LEGENDS.md) explain trial selection, statistical units and uncertainty. Illustrative successful trials are distinct from the all-trial quantitative analyses. Extended Data Fig. 5b,c show the calibration targets.

## Reproduction

Use MATLAB R2025b from the repository root.

```matlab
restoredefaultpath
run_paper_figures
```

This exports all eleven panels and both assemblies, retains the editable native figure content, and copies the source tables into `generated/paper_figures/`. The original static Fig. 6c is included. The accepted FIGs supply the manuscript's graphical presentation, with the accompanying numerical graphics specifications checked during export.

```matlab
restoredefaultpath
run_paper_model('check')
```

The bounded numerical check runs 480 primary Control/Block trials from the accepted network and compares neural predictions and behavior with the supplied references. Complete component replays are described in the [reproduction guide](docs/paper_ready/final_v3/production/REPRODUCTION.md). New output directories preserve previous runs. Required runtime inputs are version-controlled.

The [statistical methods and results](docs/paper_ready/final_v3/production/SUBMISSION_STATISTICS.md) include the eight paired temporal-noise comparisons and three shuffled prediction floors. Their features, seeds, full permutation results and reproduction code are included.

## Model and documentation

- [Model equations and parameters](docs/paper_ready/final_v3/production/MODEL.md)
- [Public model documentation](https://nirviksinha.notion.site/Cerebellar-Contributions-to-Cortical-Preparatory-Dynamics-Model-Publication-Documentation-40226c94be3081e78c1dec482828cc37)
- [Experimental figure-source repository](https://github.com/NirvikNU/Cerebellum_motor_preparation), currently access-restricted
- [Source attribution](THIRD_PARTY_PROVENANCE.md)

The shared geometry was calibrated against experimental preparatory dimensionality and alignment. Movement kinematics and prediction were excluded from calibration. Model prediction retains condition-specific preprocessing/PCA over the full trial ensemble before nested ridge cross-validation. Networks provide the uncertainty units.

The movement framework follows Kao, Sadabadi and Hennequin, *Neuron* (2021), and Hennequin, Vogels and Gerstner, *Neuron* (2014). Please cite the accompanying manuscript and the relevant upstream work when using these materials.

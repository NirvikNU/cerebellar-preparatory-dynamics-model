# Cerebellar Preparatory Dynamics Model

`v3-romano-hennequin` is the active development branch. It contains the
smoke-only scaffold for a Romano–Hennequin hybrid cortical model. No
deterministic V3 training, neural-noise training, cerebellar removal, lesion,
or adaptation experiment has run.

The V3 scaffold uses one fixed 200-by-200 recurrent matrix. Orthogonal
preparation-biased and movement-biased population bases are embedded in a
single stable, strongly non-normal recurrent operator. The synaptic matrix
does not switch at go; the target-independent go pulse can change the ReLU
active set and therefore the local effective dynamics.

Cortex receives persistent 8-D one-hot target identity and a 75-ms
target-independent go pulse. A target-only 8→12→5 cerebellar generator
relaxes with a 150-ms time constant and projects through `Ucb`. Cortical rates
are read out directly as two-dimensional velocity, and position is only its
numerical integral. There is no biomechanical plant.

Run `run_all.m` in a clean MATLAB session to execute structural and gradient
smoke tests only. The entry point does not train the model.

Historical V2 is permanently preserved by:

- branch `v2-no-plant`
- annotated tag `v2-no-plant-final`
- commit `7f8463976c0faaaebe5af653aebb12c2796ff44a`
- external archive
  `G:\My Drive\Monkey_codes\combined_analyses\cerebellar-preparatory-dynamics-model_archives\v2_no_plant_final_7f846397`

The earlier plant-based Hennequin implementation remains recoverable from
branch `v1-hennequin-isn`, tag `pre-cleanup-plant-isn`, and commit
`ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`.

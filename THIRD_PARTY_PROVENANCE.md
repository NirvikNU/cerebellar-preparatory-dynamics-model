# Source attribution

The cortical movement generator and two-link arm follow Kao, Sadabadi and Hennequin, *Neuron* (2021), “Optimal anticipatory control as a theory of motor preparation: A thalamo-cortical circuit model,” and Hennequin, Vogels and Gerstner, *Neuron* (2014).

The official upstream implementation is [hennequin-lab/optimal-preparation](https://github.com/hennequin-lab/optimal-preparation), pinned for source attribution at commit `40077d2da16e68ab2ab2cff59ec692b97315980b`. The upstream repository supplied no explicit software license at the time of inspection. The paper's CC BY 4.0 license does not itself grant a software license.

The supplied accepted network bundles contain the recurrent weights, target states, readouts, arm parameters and preparatory control inputs used by the manuscript. The repository's reproduction commands operate on these bundled assets. Core movement and arm functions are in `src/published_generator/`.

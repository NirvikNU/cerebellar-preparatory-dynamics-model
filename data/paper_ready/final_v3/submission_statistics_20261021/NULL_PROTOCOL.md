# Trial-shuffled neural prediction

Each null case uses the supplied 240-by-200 preparatory and early-movement feature matrices and the established condition-specific PCA75 and nested ridge estimator. Trial correspondence is permuted globally across the 240 response trials, preserving each complete response exactly once. Shuffles are shared across matched conditions and noise levels within each network.

For network n and permutation r, use MATLAB `RandStream('mt19937ar','Seed',352000000+100000*n+r)` and `randperm(stream,240)`. Each case has 2,000 permutations. Reusing the shared Control baseline yields 230 distinct cases and 460,000 nested null fits.

Each fit retains the original three outer folds, three inner folds and twenty-five penalties `logspace(-8,4,25)`, with the first minimum selected. Condition-specific preprocessing/PCA uses all trials before ridge cross-validation. Negative R² values are retained.

Within each case, take the median shuffled R². Within each network, take the median over eight noise levels. Report the mean and sample SEM across the ten network medians. Monte Carlo uncertainty and between-network uncertainty are recorded separately. Full inner losses, selected penalties, permutation identities and held-out SSE/SST/R² are retained in `null/`.

The reproduction function reconstructs unshuffled predictions, compares complete supplied null structures, verifies paired statistics and source tables, and checks the full-versus-half and batch Monte Carlo precision measures. The estimator, seeds and precision thresholds are fixed in the supplied source code and result objects.

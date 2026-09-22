# Independent ridge-RRR derivation and uncertainty units

The native Main_text_v8 equation (DOCX mathematical XML, not the plain-text
extraction which omits equations) is

    B_(r,lambda) = argmin rank(B)<=r [ ||Y-XB||_F^2 + lambda ||B||_F^2 ].

All centering here is on the current regression training subset only. An
unpenalized intercept is recovered as mean(Y_train)-mean(X_train)*B.
Input vectors themselves use the explicitly authorized full-ensemble
preprocessing; this is not a claim of fully inductive feature estimation.

Let A=Xc'Xc+lambda*I and C=Xc'Yc. Completing the square gives

    objective = constant + || A^(1/2) B - A^(-1/2) C ||_F^2.

For positive lambda, A is invertible, so the rank constraint is unchanged
under multiplication by A^(1/2). Eckart-Young truncation therefore applies
to T=A^(-1/2)C, not to B0=A\C in its unweighted Euclidean metric. If V_r
contains the top right singular vectors of T, the optimum is

    B_r = A\C * V_r * V_r'.

Production avoids forming a matrix square root. With economy SVD Xc=U*S*V',
the nonzero part of T is diag(s/sqrt(s^2+lambda))*U'*Yc. Multiplication on
the left by the orthonormal V does not change its right singular vectors.
This factorization is a numerical solver on all200 input/output neurons,
not a preceding PCA truncation or neural variance-selection rule.
Training-null directions carry zero fitted response; ranks above the
training response rank give the same optimum and are retained in the
predeclared1:200 grid, not removed after seeing performance.

For validation responses, write P=(Xtest-xmean)*B0*V, Z=Ytest-ymean. Since
V has orthonormal columns, SSE at rank r is

    ||Z||_F^2 + sum_(j<=r) [ ||P_j||^2 - 2 (Z V_j)' P_j ].

The cumulative form computes every rank from the same decomposition without
changing the estimator. Inner-validation SSE is pooled across all three
folds before first-minimum penalty selection, separately for each rank.
The three outer held-out SSEs are summed and divided by the pooled global
response-mean SST, never by a fold-specific or component-specific SST.

The independent implementation uses the augmented system

    Z_aug=[Xc; sqrt(lambda) I], Y_aug=[Yc; 0], Z_aug=Q R,
    M=Q' Y_aug, B0=R\M, B_r=B0 V_r V_r', V_r=right singular vectors of M.

R'R=A, so this is the same constrained objective through an independent
QR factorization. Audits explicitly form held-out predicted200-neuron
responses and their Frobenius SSE, rather than trusting cumulative losses.
Synthetic tests include both a narrow design and the full200-neuron
underdetermined design, including ranks above inner/outer training ranks.

The controller effort penalty lambda=10 is immutable and unrelated to
these CV-selected regression penalties. Panel e explicitly preserves the
previously validated mean-SSE ridge convention (n_train*lambda in the
normal equations); RRR follows the manuscript's displayed sum-SSE objective.
Both numerical grids are predeclared logspace(-8,4,25); no grid is changed
after inspecting prediction outcomes.

## Distinct uncertainty quantities

- Within one network/rank:10 complete target-stratified CV assignments;
  repeat SE=sample SD of10 pooled R2 values divided by sqrt(10). Neither
  folds nor trials are independent biological observations.
- One-SE rank: first mean-curve crossing of peak mean minus the repeat SE
  at its first peak; linearly interpolate neighboring integer ranks. No
  extrapolation below the smallest fitted rank1.
- Population summary:10 independent networks; median and SE of that median
  from the existing10000 whole-network bootstrap rows.
- Shuffle floor:100 predeclared response permutations within each policy,
  each with the full10-repeat nested procedure. Take a peak mean per
  permutation, then the median across permutations for each network. The
  ten network floor values determine population median/SE.

The empirical1000 resamples addressed unequal trial counts. They are not
added to the exactly balanced240-trial model ensemble. The manuscript's
R2 and rank outcomes are secondary held-out tests here, never selection
criteria for controllers, geometry, noise, seeds, ranks or trial exclusion.

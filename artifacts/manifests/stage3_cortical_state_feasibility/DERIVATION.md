# Stage-3 independent derivation

Verified before any model sweep. Let A=alpha U sqrt(Lambda)+beta V.
Because U'U=V'V=I and U'V=0, A'A=alpha^2 Lambda+beta^2 I.
The nonzero eigenvalues of A A' are therefore alpha^2(ell_i+rho),
rho=beta^2/alpha^2. Substitution in trace(C)^2/trace(C^2) yields
PR_B=(T+d rho)^2/(S+2 rho T+d rho^2). Subtracting T^2/S and
collecting terms yields rho(2T+d rho)(d S-T^2)/[S(S+2 rho T+d rho^2)].
Cauchy-Schwarz gives d S>=T^2, with equality for a flat spectrum.
There is no strict increase for d=1 or a flat spectrum.

Each normalized block principal direction is
(sqrt(ell_i) U_i+sqrt(rho) V_i)/sqrt(ell_i+rho).
Its projection of intact covariance is ell_i^2/(ell_i+rho).
Thus AI=sum_i ell_i^2/(ell_i+rho)/T, a weighted average of
ell_i/(ell_i+rho) with weights ell_i/T, bounded by
ell_max/(ell_max+rho). The denominator is sum ell_i, not sum ell_i^2.

For d<=7, 1-.05d is positive. If rho>(.05T-ell_min)/(1-.05d),
the smallest block eigenvalue exceeds .05 of total block variance;
d-1 PCs cannot reach >95%, so block K=d. Intact K<=d; hence common K=d.
If additionally rho>ell_max(1/eta_d-1) with eta_d>0, AI<eta_d.
The maximum of these bounds and zero is sufficient, not necessary.
Its null expectation refers to the settled intact covariance; measured
finite-window covariance/top-K denominator must be evaluated separately.
Numerical rank uses all singular values above the declared machine threshold;
the eight target-centered means have rank <=7, unlike finite trajectories.

At arbitrary x, substituting uC and b cancels both f(xB) and kappa*xB:
f(x)+uC+b-nu(x-x*)=f(x)-f(x*)-(kappa+nu)(x-x*).
Without the entire cerebellar contribution it is
f(x)-f(xB)-kappa(x-xB). The same cortical policy is used in both.
Deleting only feedback leaves x* an equilibrium; deleting b need not.
These are full-state controls, including subthreshold coordinates.

ReLU is 1-Lipschitz, so the continuous block contraction rate is at least
(1+kappa-||W||_2)/tau. Nu>=0 increases the intact lower bound. For Euler,
q=abs(1-dt*(1+gain)/tau)+(dt/tau)*||W||_2<1 is a separate sufficient
global contraction check, not merely a continuous-time pole check.

Independent synthetic tests: 126 cases, d=1..7, flat and nonuniform spectra,
three positive alpha and beta values, explicit target observations and direct
activity projection. Maximum PR/formula error 7.994e-15; PR-difference error
7.994e-15; directed-alignment error 1.777e-15. Sufficient-bound/minimum-PC
tests passed. Arbitrary-state controller identities were checked on all ten
frozen W matrices, max error 6.751e-14. No material formula failed.

Frozen norms ||W||_2 are approximately 40.387..40.720. The gain choice
kappa=max(0,||W||_2-1)+3 and nu=3 gives Euler contraction bounds .996
(block) and .992 (intact), at native .2-ms integration/tau150ms. Minimum
target-mean rates are positive in every network (.4845.. .6439 source units).
These observations ground the declared gains/support, not a behavioral search.
Code Analyzer is a separate implementation check; no sweep starts before it passes.

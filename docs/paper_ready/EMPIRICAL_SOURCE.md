# Exact empirical graphics source

Downloaded20September2026 using the authenticated Drive file stream,
without changing the source or its sharing. Source ID:
[dimensionality_alignment_epochs_raw_data.fig](https://drive.google.com/file/d/1T-3vbgRph1bbm-sl_fK0u9GiNzpwKzUT/view).
Original48341bytes and SHA256
B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F.
Provider modified13June2026,13:55:35UTC; MATLAB header created13June2026.

The original file is copied under results/paper_ready/empirical and never
saved over. paper_empirical_extract opens it invisibly, reads all graphics
objects and exports a review image. paper_empirical_audit independently
reopens it, finds named Bar objects and matches ErrorBar objects by exact
XData/YData within the same axes. Prep is the second labelled epoch.
All16series/axis/error checks pass. Visual inspection confirms the intended
pooled bars rather than the green/purple monkey-specific points.

Machine-readable full-precision values and displayed errors are in
targets.mat and targets.json; the full graphics inventory is preserved.
The FIG has no explanatory graphics UserData. Statistical semantics come
from [Main_text_v8](https://docs.google.com/document/d/1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI/edit),
modified13September2026,18:12:41.246UTC, Supplementary Figure3 and Analysis
of neural population structure: pooled motor-cortical neurons1048+3824,
medians and SD across1000 trial-balanced resamples, native empirical rate
estimation, full-reference control neuronwise SD with1Hzfloor, target
centering and K15 covariance-constrained control. No source manuscript edit.

Do not interpret model source-rate units as Hz, model n10bootstrapSE as the
experimental resampleSD,30independent model trials as1000experimental
trial-balancing resamples, or the difference of marginal bar medians as
necessarily the median of paired resample-wise differences. The authorized
loss explicitly uses differences of exact bars; paired-effect uncertainty
cannot be recovered from marginal error bars without their covariance.
No screenshot estimate or guessed paired uncertainty enters calibration.

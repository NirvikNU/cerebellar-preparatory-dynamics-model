# Final manuscript model specification

Use [Frozen manuscript model](docs/paper_ready/final_v3/production/MODEL.md), [reproduction scope](docs/paper_ready/final_v3/production/REPRODUCTION.md) and [panel definitions/statistics](docs/paper_ready/final_v3/production/LEGENDS.md).

Ten accepted200-unit ReLU networks and eight targets are frozen. eta=0, lambda=10, V=1, global alpha=.5/beta_norm=1.25. No residual kappa feedback. For f(x)=−x+WReLU(x)+h, base=−f(xB), b=f(xB)−f(x*). Control has base+b−L(x−x*); target-specific-only has base+b; anticipatory-control-only has base−L(x−x*); Block has base.

Native integration is0.2ms, saved sampling1ms, analysis sampling10ms. Primary noise .10/.10, Fig6g,h eight-level one-factor sweeps .05,.10,.15,.20,.25,.30,.35,.40 with the other noise fixed at .05; shared .05/.05 anchor. Noise stops at GO. Accepted network, movement, readout, arm, preprocessing, PCA75/ridge and inference parameters are immutable.

ED5b/c explicitly show calibration targets, not independent validation. Success-conditioned Fig6d–f examples do not define behavioral inference. Final figures are Fig6a–h and ED5a–c. The exact K=0 sweep endpoint has zero feedback but retains tonic input.

Foundation construction and older Stage1/2/3 diagnostics are historical scientific provenance, retained separately. Their task-specific conditions are not alternatives to the frozen paper model and grant no execution authority.

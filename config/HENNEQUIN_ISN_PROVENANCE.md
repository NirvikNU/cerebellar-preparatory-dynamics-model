# Hennequin recurrent scale-reference provenance

The retained asset `why_prep_2_w_rec.txt` is an unchanged copy of the fixed
recurrent matrix distributed with Schimel, Kao, and Hennequin (2024).

- Source repository: `https://github.com/marineschimel/why-prep-2`
- Source commit: `09d1949a43c0b5066a888b0ceb2a951e70539992`
- Source path: `data/w_rec`
- Local path: `config/why_prep_2_w_rec.txt`
- SHA-256:
  `1E5DC654FD9EAE46E2F01C0BB67118378CE6AE9007227A1A3BF5488EA39B411D`

V3 does not use this file as its recurrent matrix. It verifies the file hash
at runtime and uses its spectral abscissa and Frobenius norm only as
conservative scale references for the deterministic hybrid constructor.
Historical V2 used the official matrix directly and remains preserved by
branch `v2-no-plant`, tag `v2-no-plant-final`, and the external V2 archive.

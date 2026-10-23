# Main_text_v13: ED5 naming migration — 23 October 2026

Current production names are Fig6a–h and ED5a–c, with Figure_6 and Extended_Data_Figure_5 assemblies. Scientific values, accepted networks, model parameters, seeds, illustrative selections, calibration, prediction estimates and uncertainty are unchanged from release `769fa3c2ace09a64afef61e02dfc7209e04c5a3f`.

| Historical identifier | Current identifier |
|---|---|
| ED7a | ED5a |
| ED7b | ED5b |
| ED7c | ED5c |
| ED7bc source-table prefix | ED5bc |
| Extended_Data_Figure_7 | Extended_Data_Figure_5 |

The exact path/reference map is `data/paper_ready/final_v3/ed5_migration.json`. Panel FIG/PNG masters, the assembly, graphics recipes and persisted graphical fixtures are renamed with original bytes intact. The original FIG containers therefore retain their historical UserData identifiers internally; regenerated FIGs use ED5 identifiers. FileName is independently verified against the loaded path. Only specified root UserData panel/assembly/panels identifiers and verified derived-texture identifiers are mapped for native equality. No axes, annotations, scientific arrays, layout or style property is omitted.

CSV/JSON source records containing panel labels have only those explicit labels changed. Every numeric token and all other bytes remain exact. The migration map records each reversible replacement and old/new SHA256; the validator reverses these changes before checking the original committed Git blob. All other sources require original blob-byte equality. Historical panel_provenance sourcePath fields remain tied to their original commit and are never rewritten to fictional historical ED5 paths.

## Graphical policy and independent validation

The approved policy remains byte-identical, SHA256 `98B575FDC9E76E7FE294941B1A112B0DE535127CDD269FAD401EE62476AF08A8`. Only its identifiers resolve through the fixed migration. Coordinate sets, complete RGBA palettes, dimensions, environment restrictions and all scientific/native requirements are unchanged. Unknown pixels, colors, geometry or environment stop validation. The fixed migration map itself has a hard-coded SHA256 in the validator and cannot expand automatically.

Run the commands in [REPRODUCTION.md](REPRODUCTION.md) and [SUBMISSION_STATISTICS.md](SUBMISSION_STATISTICS.md) from repository-only inputs. Acceptance requires 11 panels, two assemblies, 261 native data objects, complete native-property graphs, 26 source tables, the actual bounded 480-trial check, and exact reproduction of all eight paired tests and three 2,000-shuffle summaries. Post-push receipts must come from an independently downloaded GitHub clone at the released SHA. A command specification alone does not assert execution; the dated Agent Log contains actual receipts.

## Historical and website boundaries

The ED7d retirement archive, all historical Git commits, dated validation/cleanup receipts and completed exploratory analyses remain unchanged. Historical receipts describe the labels used when run, not an alternative current interface. The 13 October cleanup and 19 October noise/presentation documents retain their dated evidence; no repeat cleanup is part of this task. Fig6c is the original hand-drawn static schematic.

The experimental figure-source collection is [Cerebellum_motor_preparation](https://github.com/NirvikNU/Cerebellum_motor_preparation). It provides figure-level sources, not the complete experimental analysis pipeline. Its ED5 assets are separate from this model's generation interface.

The existing Notion site was anonymously readable on 23 October 2026, including the internal Handoff and local run history. Publication-site curation is blocked pending owner approval of separation/access controls; no permissions were changed. A standalone curated public page without internal children is proposed. Its eventual URL must be checked anonymously before it is promoted as the publication website; changing the manuscript Code Availability URL remains the author's action. Neither Google Doc is edited by this migration.

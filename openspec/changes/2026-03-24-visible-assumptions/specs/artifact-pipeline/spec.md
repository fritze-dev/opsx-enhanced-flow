## Assumptions

- The OpenSpec CLI enforces artifact dependency checks before generation. If the CLI does not enforce this natively, skills must implement the checks. <!-- ASSUMPTION: CLI dependency enforcement -->
- Artifact completion is determined by file existence and non-empty content, not by content validation or quality assessment. <!-- ASSUMPTION: File-existence-based completion -->
- Agent compliance with instruction-based guidance is sufficient for consolidation enforcement. The Consolidation Check template section provides a reviewable artifact as enforcement. <!-- ASSUMPTION: Agent compliance sufficient -->
- The constitution is read during task generation via the config.yaml context directive, which already points agents to the constitution. <!-- ASSUMPTION: Config-based constitution loading -->
- Verbatim copy means the agent transfers the exact markdown text without rewriting, reordering, or interpreting the items. <!-- ASSUMPTION: Verbatim means exact copy -->
No further assumptions beyond those marked above.

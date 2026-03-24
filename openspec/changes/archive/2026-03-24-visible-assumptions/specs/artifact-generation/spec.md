## Assumptions

- The OpenSpec CLI provides commands to query change status (`openspec status`) and retrieve artifact instructions (`openspec instructions`) that the skills can invoke. <!-- ASSUMPTION: CLI command availability -->
- The OpenSpec CLI determines artifact completion by checking file existence in the change workspace directory. <!-- ASSUMPTION: File-existence-based completion -->
- The continue skill's Artifact Creation Guidelines are supplementary to the schema instructions. Both are read by the agent when creating artifacts. <!-- ASSUMPTION: Supplementary guidelines -->
No further assumptions beyond those marked above.

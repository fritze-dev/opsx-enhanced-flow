## Assumptions

- The bootstrap command can reliably detect tech stack and conventions from static file analysis (file extensions, configuration files, package manifests) without executing any project code. <!-- ASSUMPTION: Static analysis sufficient -->
- Recovery mode's drift detection compares structural and naming patterns rather than performing deep semantic analysis of code behavior. <!-- ASSUMPTION: Structural comparison -->
No further assumptions beyond those marked above.

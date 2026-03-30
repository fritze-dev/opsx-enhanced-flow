## Assumptions

- npm global install (`npm install -g`) is the correct installation method for the OpenSpec CLI. This assumes the user's Node.js environment supports global installs. <!-- ASSUMPTION: Global install method -->
- The `^1.2.0` version constraint is enforced via npm semver, meaning any version >= 1.2.0 and < 2.0.0 is acceptable. <!-- ASSUMPTION: Semver enforcement -->
- `openspec schema init` works independently without prior `openspec init`. Verified by testing in a clean directory. <!-- ASSUMPTION: Independent schema init -->
No further assumptions beyond those marked above.

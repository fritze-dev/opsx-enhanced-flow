#!/bin/bash
set -e

# Only run in Claude Code Web
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

echo "Setting up opsx-enhanced-flow for Claude Code Web..."

# Install gh CLI (not pre-installed in cloud sessions)
if ! command -v gh &> /dev/null; then
  echo "Installing GitHub CLI..."
  apt update && apt install -y gh
fi

# Configure gh auth if GH_TOKEN is available
if [ -n "$GH_TOKEN" ]; then
  echo "GH_TOKEN found — gh CLI authenticated."
  gh auth setup-git
else
  echo "WARNING: No GH_TOKEN found. gh pr create and gh release will not work."
  echo "Add GH_TOKEN as environment variable in your Claude Code Web environment settings."
fi

echo "Setup complete."

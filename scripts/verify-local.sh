#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command node
require_command npm
require_command uv

node_major="$(node --version | sed -E 's/^v([0-9]+).*/\1/')"
if ((node_major < 20)); then
  echo "Node.js 20 or later is required; found $(node --version)." >&2
  exit 1
fi

echo "Verifying backend"
(
  cd "$repository_root/backend"
  npm run format:check
  npm run lint
  npm test
  npm run build
)

echo "Verifying frontend"
(
  cd "$repository_root/frontend"
  npm run format:check
  npm run build
)

echo "Verifying CDK"
(
  cd "$repository_root/cdk"
  npm test -- --runInBand
  npm run build
)

echo "Verifying review agent"
(
  cd "$repository_root/review-item-processor"
  uv run pytest
)

echo "All local verification checks passed."

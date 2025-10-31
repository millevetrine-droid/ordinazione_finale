#!/usr/bin/env bash
set -euo pipefail

# This script runs inside firebase emulators:exec on CI runners.
# It installs tooling deps, generates a staff idToken, then runs the Dart test that
# exercises the Firestore emulator via REST.

echo "Running emulator test script..."

cd "$(dirname "$0")/.." # move to tooling
echo "Tooling dir: $(pwd)"

echo "Installing npm deps..."
# Prefer npm ci for reproducible installs when a package-lock.json is present.
if [ -f package-lock.json ]; then
	echo "package-lock.json found -> npm ci"
	npm ci
else
	echo "package-lock.json not found -> npm install"
	npm install
fi

echo "Generating staff idToken..."
npm run gen-token
echo "Running Node end-to-end auth+rules test (no Flutter required)..."
cd .
node session_auth_test.js

echo "Done run_emulator_tests.sh"

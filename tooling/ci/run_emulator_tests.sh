#!/usr/bin/env bash
set -euo pipefail

# This script runs inside firebase emulators:exec on CI runners.
# It installs tooling deps, generates a staff idToken, then runs the Dart test that
# exercises the Firestore emulator via REST.

echo "Running emulator test script..."

cd "$(dirname "$0")/.." # move to tooling
echo "Tooling dir: $(pwd)"

echo "Installing npm deps..."
# Use npm install in CI to tolerate missing package-lock.json in some checkouts.
# `npm ci` requires package-lock.json; using `npm install` is slightly slower but
# more robust for CI runs where package-lock may not be present.
npm install

echo "Generating staff idToken..."
npm run gen-token

echo "Running flutter test for emulator REST tests..."
cd ..
flutter test test/session_emulator_rest_test.dart -r expanded

echo "Done run_emulator_tests.sh"

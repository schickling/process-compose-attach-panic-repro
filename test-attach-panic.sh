#!/bin/bash
set -e

echo "Starting process-compose in background..."
process-compose up --tui=false -p 8080 &
PC_PID=$!

echo "Waiting for process-compose to start..."
sleep 3

echo "Attempting to attach to test-process (this should panic)..."
process-compose attach test-process -p 8080

echo "If you see this message, the attach command worked (unexpected!)"

# Cleanup
kill $PC_PID 2>/dev/null || true
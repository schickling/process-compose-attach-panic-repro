# process-compose attach panic reproduction

This repository provides a minimal reproduction case for the `process-compose attach` command panic reported in [F1bonacc1/process-compose#364](https://github.com/F1bonacc1/process-compose/issues/364).

## Problem

The `process-compose attach` command consistently panics with `panic: close of nil channel` when attempting to attach to any process.

## Environment

- **OS**: Linux 6.1.35 #1-NixOS SMP PREEMPT_DYNAMIC (x86_64)  
- **Terminal**: xterm-256color
- **Go version**: go1.24.5 linux/amd64
- **Tested versions**: v1.64.1, v1.73.0

## Quick reproduction

1. Download process-compose v1.73.0:
```bash
curl -L https://github.com/F1bonacc1/process-compose/releases/download/v1.73.0/process-compose_linux_amd64.tar.gz -o process-compose.tar.gz
tar -xzf process-compose.tar.gz
```

2. Clone this repository:
```bash
git clone https://github.com/schickling/process-compose-attach-panic-repro.git
cd process-compose-attach-panic-repro
```

3. Run the test script:
```bash
chmod +x test-attach-panic.sh
./test-attach-panic.sh
```

## Manual steps

1. Start process-compose:
```bash
process-compose up --tui=false -p 8080
```

2. In another terminal, attempt to attach:
```bash
process-compose attach test-process -p 8080
```

## Expected vs Actual

**Expected**: The attach command should open a TUI interface showing the process output.

**Actual**: The command immediately panics with:
```
panic: close of nil channel

goroutine 1 [running]:
github.com/gdamore/tcell/v2.(*tScreen).finish(...)
    /home/eugene/go/pkg/mod/github.com/gdamore/tcell/v2@v2.8.1/tscreen.go:683
[... stack trace continues ...]
```

## Variations tested (all fail)

- ✅ Standard TCP connection (`-p 8080`)
- ✅ Unix domain sockets (`-U`)  
- ✅ With `NO_PROXY="$NO_PROXY,unix"` environment variable
- ✅ Different process names (`test-process`, `another-process`)
- ✅ Different process-compose versions (v1.64.1, v1.73.0)

## Impact

This makes the `attach` command completely unusable, forcing users to rely on:
- Log file monitoring (`tail -f process-compose.log`)
- Direct process inspection (`ps aux`)
- HTTP API endpoints

## Files

- [`process-compose.yaml`](./process-compose.yaml) - Minimal configuration with two simple processes
- [`test-attach-panic.sh`](./test-attach-panic.sh) - Automated reproduction script
- [`README.md`](./README.md) - This documentation
#!/usr/bin/env bash
# Run EVERY testbench under tb/. This is the project's main test command -
# used locally (Git Bash on Windows) and by CI. No make required.
#
#     scripts/test-all.sh           run all testbenches
#     scripts/test-all.sh --list    just list what would run
#
# Exits 0 only if every testbench compiles and passes.
# Exits 0 with a notice if there are no testbenches yet (keeps CI green pre-Week 1).

set -uo pipefail

IVERILOG="${IVERILOG:-iverilog}"
VVP="${VVP:-vvp}"
FLAGS="${FLAGS:--g2012 -Wall -Wno-timescale -I rtl}"

cd "$(dirname "$0")/.."

mapfile -t TBS < <(find tb -name 'tb_*.sv' 2>/dev/null | sort)

if [ "${1:-}" = "--list" ] || [ "${1:-}" = "-l" ]; then
  if [ "${#TBS[@]}" -eq 0 ]; then
    echo "(no testbenches yet - add tb/<subsystem>/tb_<name>.sv)"
  else
    for f in "${TBS[@]}"; do echo "  $(basename "$f" .sv)   <- $f"; done
  fi
  exit 0
fi

if [ "${#TBS[@]}" -eq 0 ]; then
  echo "No testbenches under tb/ yet - nothing to run."
  exit 0
fi

for t in "$IVERILOG" "$VVP"; do
  command -v "$t" >/dev/null 2>&1 || {
    echo "ERROR: '$t' not found on PATH. Run scripts/check-tools.sh"
    exit 127
  }
done

mkdir -p sim
mapfile -t RTL < <(find rtl -name '*.v' 2>/dev/null | sort)

pass=0; fail=0; failed_names=()

for tb_path in "${TBS[@]}"; do
  name="$(basename "$tb_path" .sv)"
  echo "=== $name ==="
  if ! "$IVERILOG" $FLAGS -o "sim/${name}.vvp" -s "$name" "${RTL[@]}" "$tb_path"; then
    echo "COMPILE FAILED: $name"
    fail=$((fail+1)); failed_names+=("$name (compile)"); continue
  fi
  if "$VVP" "sim/${name}.vvp"; then
    pass=$((pass+1))
  else
    fail=$((fail+1)); failed_names+=("$name (runtime)")
  fi
done

echo "------------------------------"
echo "$pass passed, $fail failed, ${#TBS[@]} total"
if [ "$fail" -gt 0 ]; then
  echo "FAILED:"
  for n in "${failed_names[@]}"; do echo "  - $n"; done
  exit 1
fi
echo "ALL TESTBENCHES PASSED"
exit 0

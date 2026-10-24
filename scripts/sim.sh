#!/usr/bin/env bash
# Run a single testbench without make. Useful on Windows under Git Bash.
#
#   scripts/sim.sh tb_gates          compile + run
#   scripts/sim.sh tb_gates --wave   compile + run, then open GTKWave
#   scripts/sim.sh --list            list available testbenches
#
# Exits non-zero if compilation or the testbench itself fails.

set -euo pipefail

IVERILOG="${IVERILOG:-iverilog}"
VVP="${VVP:-vvp}"
GTKWAVE="${GTKWAVE:-gtkwave}"
FLAGS="${FLAGS:--g2012 -Wall -Wno-timescale -I rtl}"

cd "$(dirname "$0")/.."

list_tests() {
  find tb -name 'tb_*.sv' 2>/dev/null | sort | while read -r f; do
    echo "  $(basename "$f" .sv)   <- $f"
  done
}

if [ $# -lt 1 ] || [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
  echo "Available testbenches:"
  if [ -z "$(find tb -name 'tb_*.sv' 2>/dev/null)" ]; then
    echo "  (none yet - add tb/<subsystem>/tb_<name>.sv)"
  else
    list_tests
  fi
  [ $# -lt 1 ] && { echo; echo "Usage: scripts/sim.sh <tb_name> [--wave]"; exit 1; }
  exit 0
fi

TB="$1"
WANT_WAVE="${2:-}"

for t in "$IVERILOG" "$VVP"; do
  command -v "$t" >/dev/null 2>&1 || {
    echo "ERROR: '$t' not found on PATH."
    echo "Install Icarus Verilog v12 (64-bit) from https://bleyer.org/icarus/ with 'Add to PATH' ticked."
    exit 127
  }
done

TB_PATH="$(find tb -name "${TB}.sv" 2>/dev/null | head -1)"
if [ -z "$TB_PATH" ]; then
  echo "ERROR: no testbench named '${TB}.sv' under tb/"
  echo "Available:"; list_tests
  exit 1
fi

mkdir -p sim
mapfile -t RTL < <(find rtl -name '*.v' 2>/dev/null | sort)

echo "=== $TB ==="
echo "    tb:  $TB_PATH"
echo "    rtl: ${#RTL[@]} file(s)"

"$IVERILOG" $FLAGS -o "sim/${TB}.vvp" -s "$TB" "${RTL[@]}" "$TB_PATH"
"$VVP" "sim/${TB}.vvp"

if [ "$WANT_WAVE" = "--wave" ] || [ "$WANT_WAVE" = "-w" ]; then
  if [ -f "sim/${TB}.vcd" ]; then
    command -v "$GTKWAVE" >/dev/null 2>&1 && "$GTKWAVE" "sim/${TB}.vcd" &
  else
    echo "NOTE: sim/${TB}.vcd not produced - does the testbench call \$dumpfile/\$dumpvars?"
  fi
fi

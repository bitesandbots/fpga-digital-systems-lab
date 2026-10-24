#!/usr/bin/env bash
# Verify the toolchain without needing make. Run from Git Bash:
#     scripts/check-tools.sh
# Exits non-zero if anything required is missing.

cd "$(dirname "$0")/.."

req_missing=0
opt_missing=0

check() {
  local tool="$1" required="$2" hint="$3"
  printf '  %-12s ' "$tool"
  if command -v "$tool" >/dev/null 2>&1; then
    local v
    v="$("$tool" --version 2>&1 | head -1)"
    [ -z "$v" ] && v="$("$tool" -V 2>&1 | head -1)"
    echo "OK       ${v:0:58}"
  else
    if [ "$required" = "required" ]; then
      echo "MISSING  $hint"
      req_missing=$((req_missing+1))
    else
      echo "absent   (optional) $hint"
      opt_missing=$((opt_missing+1))
    fi
  fi
}

echo "Required now (Weeks 1-3):"
check git      required "https://git-scm.com/download/win"
check iverilog required "Icarus v12 64-bit, https://bleyer.org/icarus/ - tick 'Add to PATH'"
check vvp      required "ships with Icarus Verilog"
check gtkwave  required "bundled with the Icarus Windows installer"

echo
echo "Required later:"
check python   optional "Week 9 (assembler) and Week 11 (DSP vectors)"
check make     optional "not needed locally - CI runs it; use scripts/sim.sh instead"

echo
echo "Repo check:"
printf '  %-12s ' "testbenches"
n=$(find tb -name 'tb_*.sv' 2>/dev/null | wc -l | tr -d ' ')
if [ "$n" = "0" ]; then echo "0        (expected until Week 1)"; else echo "$n found"; fi

printf '  %-12s ' "rtl files"
r=$(find rtl -name '*.v' 2>/dev/null | wc -l | tr -d ' ')
echo "$r"

echo
if [ "$req_missing" -gt 0 ]; then
  echo "RESULT: $req_missing required tool(s) missing - install them, then re-run this."
  exit 1
fi
echo "RESULT: all required tools present. Gate G0 toolchain check PASSED."
echo "Next: scripts/sim.sh --list   (will be empty until Week 1)"
exit 0

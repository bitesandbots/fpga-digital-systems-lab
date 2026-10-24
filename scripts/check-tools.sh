#!/usr/bin/env bash
# Verify the toolchain without needing make. Run from Git Bash:
#     scripts/check-tools.sh
# Exits non-zero if anything required for the CURRENT stage is missing.

cd "$(dirname "$0")/.."

req_missing=0
warnings=0

# Does this look like a real version string, or an error / Windows Store stub?
looks_bogus() {
  case "$1" in
    ""|*"unknown option"*|*"was not found"*|*"Microsoft Store"*|*"not recognized"*|*"No such file"*) return 0 ;;
    *) return 1 ;;
  esac
}

# version_of <tool> -> prints first sane version line, empty if none
version_of() {
  local tool="$1" out
  for flag in "$2" "$3" "$4"; do
    [ -z "$flag" ] && continue
    out="$("$tool" "$flag" 2>&1 | head -1)"
    looks_bogus "$out" || { echo "$out"; return 0; }
  done
  echo ""
}

# check <tool> <required|later> <version flags...> -- <hint>
check() {
  local tool="$1" tier="$2" f1="$3" f2="$4" f3="$5" hint="$6"
  printf '  %-12s ' "$tool"
  if ! command -v "$tool" >/dev/null 2>&1; then
    if [ "$tier" = "required" ]; then
      echo "MISSING  $hint"; req_missing=$((req_missing+1))
    else
      echo "absent   $hint"
    fi
    return
  fi
  local v; v="$(version_of "$tool" "$f1" "$f2" "$f3")"
  if [ -z "$v" ]; then
    # On PATH but gives no usable version: on Windows this is usually an
    # App Execution Alias stub that is not the real program.
    if [ "$tier" = "required" ]; then
      echo "BROKEN   on PATH but not runnable. $hint"; req_missing=$((req_missing+1))
    else
      echo "absent   not really installed (stub on PATH). $hint"
    fi
    return
  fi
  echo "OK       ${v:0:60}"
  if [ "$tool" = "iverilog" ]; then
    local maj; maj="$(echo "$v" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)"
    if [ -n "$maj" ] && [ "$maj" -lt 12 ] 2>/dev/null; then
      echo "               ^ WARNING: v$maj. The roadmap's SystemVerilog testbenches"
      echo "                 need v12+. Reinstall v12 from https://bleyer.org/icarus/"
      warnings=$((warnings+1))
    fi
  fi
}

echo "Required now (Weeks 1-3):"
check git      required --version ""   "" "https://git-scm.com/download/win"
check iverilog required -V         ""   "" "Icarus v12 64-bit, https://bleyer.org/icarus/ - tick 'Add to PATH'"
check vvp      required -V         ""   "" "ships with Icarus Verilog"
check gtkwave  required --version  -V   "" "bundled with the Icarus Windows installer"

echo
echo "Needed by Week 9 (Dec 21) - not blocking now:"
check python   later --version "" "" "install from https://www.python.org/downloads/ and tick 'Add python.exe to PATH'"
check python3  later --version "" "" "(alternative name for python)"
check make     later --version "" "" "not needed locally - CI runs it; use scripts/sim.sh instead"

echo
echo "Repo check:"
printf '  %-12s ' "testbenches"
n=$(find tb -name 'tb_*.sv' 2>/dev/null | wc -l | tr -d ' ')
if [ "$n" = "0" ]; then echo "0        (expected until Week 1)"; else echo "$n found"; fi
printf '  %-12s ' "rtl files"
echo "$(find rtl -name '*.v' 2>/dev/null | wc -l | tr -d ' ')"

# Is some form of python available under any name?
py_ok=0
for c in python python3 py; do
  command -v "$c" >/dev/null 2>&1 && { v="$(version_of "$c" --version)"; [ -n "$v" ] && py_ok=1; }
done

echo
if [ "$req_missing" -gt 0 ]; then
  echo "RESULT: $req_missing required tool(s) missing or broken."
  echo "        Install them, reopen Git Bash, and re-run this script."
  exit 1
fi
echo "RESULT: Gate G0 toolchain check PASSED (Weeks 1-8 can proceed)."
[ "$warnings" -gt 0 ] && echo "        $warnings warning(s) above - read them."
if [ "$py_ok" -eq 0 ]; then
  echo
  echo "TODO before Week 9: no working Python found."
  echo "  Install from https://www.python.org/downloads/ - during setup tick"
  echo "  'Add python.exe to PATH'. Needed for the tiny8 assembler (Week 9)"
  echo "  and the DSP reference vectors (Week 11). Not needed before then."
fi
echo
echo "Next: scripts/sim.sh --list   (empty until Week 1)"
exit 0

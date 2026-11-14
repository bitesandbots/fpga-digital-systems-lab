# FPGA Project — Weekly Progress Log

**This file is the single source of truth for project status.**
Maintained by Claude, updated at the end of every work session. Lives at
`docs/PROGRESS.md` in this repo — there is deliberately no second copy anywhere else.

Claude: read this first each session, before `docs/WEEKLY_ROADMAP.md`.

- **Repo:** https://github.com/bitesandbots/fpga-digital-systems-lab
- **Target:** 2027 college application cycle — no deadline pressure
- **Pace:** 4–8 hrs/week, ~72 hrs total
- **Rule:** a week is done when its **gate** is met, not after seven days. No calendar dates.

---

## At a glance

| Wk | Theme | Gate | Status | Commit | Notes |
|---|---|---|---|---|---|
| 0 | Environment setup | G0 | ✅ **DONE** | `be4b080` | CI green on run #3 |
| 1 | Setup + first HDL | G1a | 🟡 **pushed** | `40797a8` | awaiting CI green + evidence + notes |
| 2 | Combinational logic | G1 | ⬜ | — | **order the Basys 3 this week** |
| 3 | Sequential logic | — | ⬜ | — | **start the Vivado download this week** |
| 4 | First FPGA hardware | G2 | ⬜ | — | needs board + Vivado |
| 5 | PWM | G3 | ⬜ | — | |
| 6 | UART TX | — | ⬜ | — | |
| 7 | UART RX + loopback | G4 | ⬜ | — | |
| 8 | CPU foundations | — | ⬜ | — | student writes the ISA spec first |
| 9 | tiny8 CPU core | — | ⬜ | — | needs Python ✅ |
| 10 | CPU on FPGA | G5 | ⬜ | — | headline milestone |
| 11 | Intro DSP block | G6 | ⬜ | — | needs Python ✅ |
| 12 | Integration + polish | G7 | ⬜ | — | |

Legend: ✅ done · 🟡 in progress · ⬜ not started · ⛔ blocked

---

## NEXT ACTION

**Week 1 — tests pass; finish the gate.** `scripts/test-all.sh` → `PASS: tb_gates
(14 checks)`, 1 passed / 0 failed, on the first run.

Remaining for **Gate G1a**:
1. Commit and push (includes the `.gitignore` fix below), then confirm the Actions tab
   goes green on `main`.
2. Capture `results/week01/week01-first-sim.png` — terminal showing PASS, plus a
   GTKWave shot from `scripts/sim.sh tb_gates --wave`.
3. Write `docs/week-01-notes.md` in his own words: what a module's port list physically
   is, `wire` vs `reg`, why `=` in an `assign` is not Python assignment. Start
   `docs/lessons-learned.md`. Claude deliberately does not write these.
4. Be able to say out loud why all four gates compute at the same instant rather than
   in order.

**Then Week 2** — mux, decoder, full adder, 4-bit ripple-carry adder with 512
exhaustive checks. **Order the Basys 3 that week** (`410-183`, $165 direct from
Digilent, plus cable `310-053`, $6) so it arrives before Week 4.

---

## Completed weeks

### Week 1 — Setup + first HDL 🟡 IN PROGRESS

**Simulation passes: `PASS: tb_gates (14 checks)`, 1 passed / 0 failed, first run.**
Committed and pushed as `41b420c` (gates), `646e7e8` (testbench), `40797a8` (gitignore
+ progress). Gate G1a not yet fully met — still needs CI green, evidence capture,
and the student's own notes.

**Delivered:** `rtl/gates/gate_and.v`, `gate_or.v`, `gate_xor.v`, `gate_not.v`
(Verilog-2005, continuous `assign`, each wrapped in `` `default_nettype none ``),
and `tb/gates/tb_gates.sv` — 14 exhaustive checks (4 combinations x 3 two-input
gates, plus 2 for the inverter), VCD dump, `$fatal(1)` on failure, 1 ms watchdog.
Plus `results/week01/.gitkeep`.

**What went wrong:**

1. **Claude could not verify its own code.** `iverilog` is not installed in the
   sandbox VM that reaches the repo, and that VM has no apt or pypi access, so no
   simulator could be installed anywhere on Claude's side. Code was therefore written
   defensively — plain `for (i = 0; ...)` with a module-level `int i` rather than an
   inline loop variable, explicit bit masking instead of part-selects on `int` — to
   avoid constructs that could not be checked. This is a standing constraint, not a
   one-off: **the student runs the tests.**
2. **The roadmap's week headings were corrupted** by a bad regex in the previous
   session: every heading read `# Week 1 — 1Setup + first HDL`, with the week number
   duplicated into the title. All 13 repaired. Cause: a `re.split` with a capturing
   group re-inserted the captured number when the sections were rejoined.

3. **A planning spreadsheet was committed to the public repo.** `git add -A` in
   the Week 0 tip commit swept in `WeeklyPlan_Learning_Material.xlsx`, because `.gitignore`
   named the original workbook by exact filename rather than by pattern. The sheet
   holds no personal data, but it does contain a "Parent/Mentor Check" column and
   "Major admissions milestone" — framing that undercuts the portfolio if a reader
   finds it. Fixed by replacing the literal filename with `*.xlsx` and running
   `git rm --cached`. History was then rewritten: the file was added in the tip
   commit only, so `git commit --amend` + `git push --force-with-lease` erased it
   completely (`84684eb` -> `be4b080`). Verified gone from both tracking and history.

**Lesson:** the Week 0 lesson repeated in a new form — Claude asserting code is correct
is not evidence. Only the test run is. The 🟡 state exists precisely so "written" is
never silently recorded as "working." It paid off here: the code did pass first try,
but it was recorded as unverified until a real run proved it.

**Second lesson:** `git add -A` commits whatever happens to be lying around. An ignore
rule that names one exact file protects exactly one file.

### Week 0 — Environment setup ✅

**Gate G0 met.** All four checks pass.

| Check | Result |
|---|---|
| Toolchain installed | ✅ git 2.54, Icarus (`C:\iverilog\bin`), GTKWave 3.3.100, Python 3.14.5 |
| `scripts/test-all.sh` runs clean | ✅ exits 0 |
| Pushed to GitHub | ✅ `be4b080`, working tree clean |
| Green check on Actions | ✅ simulate run #3 |

**Delivered:** `scripts/test-all.sh`, `scripts/sim.sh`, `scripts/check-tools.sh`,
`.github/workflows/ci.yml`, full `.gitignore`, MIT `LICENSE`, `rtl/`+`tb/` skeleton.
30 files tracked, 8 commits.

**What went wrong, and the fixes** (worth keeping — these are real lessons):

1. **CI run #2 failed, exit 126 Permission denied.** The repo is authored on Windows
   where `core.filemode=false`, so `chmod +x` was never recorded — scripts entered the
   index as `100644` and Ubuntu refused to run them. Fixed three ways:
   `git update-index --chmod=+x`, `bash scripts/...` in CI, and `*.sh text eol=lf`
   in `.gitattributes`.
2. **`make` was dropped entirely.** Not bundled with Git for Windows, needs a Unix
   shell, and keeping two test runners risked them drifting with only the unused one
   under CI. The Makefile was retired.
3. **`check-tools.sh` shipped with two false-PASS bugs.** Icarus uses `-V` not
   `--version` (so an error string was printed as the version), and Windows' App
   Execution Alias stub for `python` satisfied `command -v` on a machine with no
   Python. Both fixed; output that looks like an error or a Store stub is now rejected.
4. **Python aliases were split across two packages** (Store `qbz5n2kfra8p0` vs
   python.org `3847v3x7pw1km`), so `python` and `py` resolved to different installs.
   Fixed by enabling every python.org entry and disabling every Store entry.

**Lesson worth carrying into the testbenches:** a tool that reports PASS when it should
report FAIL is worse than no tool. Verify tooling against a deliberately broken case
before trusting a green result.

---

## Open items

| Item | When | Status |
|---|---|---|
| Order Basys 3 (`410-183`, $165 direct from Digilent) + micro-USB cable (`310-053`, $6) | **Week 2** | ⬜ not ordered |
| Ask a Digilent distributor about the ~15% academic discount (~$25) | before ordering | ⬜ |
| Start Vivado download, **Artix-7 only** (~30–50 GB) | **Week 3** | ⬜ |
| Check free disk space before the Vivado install (want 100 GB) | before Week 3 | ⬜ unverified |

## Blockers

None.

---

## How to update this file

At the end of a work session: flip the week's Status, add its commit SHA, and write a
"Completed weeks" entry covering what was delivered, what broke, and what it taught.
Then move NEXT ACTION to the following week. Keep the failure notes — they are the
lessons-learned and essay material, and deleting them loses the most valuable part.

## Session workflow note

This sandbox's git is unreliable against the OneDrive folder (undeletable `.git/*.lock`
files, and no network to push). **Claude writes files; the student runs git** from
Git Bash. Give exact commands rather than attempting commits here.

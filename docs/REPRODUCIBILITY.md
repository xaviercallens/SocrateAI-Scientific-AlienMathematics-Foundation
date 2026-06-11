# Scientific Reproducibility Guide

## Purpose

This document provides a **complete, step-by-step procedure** for independently reproducing the formal verification of the Alien Mathematics framework. Every theorem in `Agora/AlienMath/` has been machine-checked by the Lean 4 kernel — this guide allows any researcher to verify that claim from scratch on their own hardware.

> **No proprietary tools are required.** The entire verification pipeline uses open-source software and publicly available dependencies.

---

## Prerequisites

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| **OS** | Linux (x86_64), macOS (arm64/x86_64) | Ubuntu 22.04+, macOS 14+ |
| **RAM** | 4 GB | 8 GB |
| **Disk** | 8 GB free | 16 GB free |
| **CPU** | Any modern x86_64 or arm64 | 4+ cores |
| **Tools** | `git`, `curl`, `python3 ≥ 3.10` | + `grep`, `jq` |
| **Network** | Required for initial setup | Cache download ~2 GB |

---

## Quick Reproduction (5 minutes)

```bash
# 1. Clone
git clone https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation.git
cd SocrateAI-Scientific-AlienMathematics-Foundation

# 2. Run the automated reproducer
chmod +x scripts/reproduce.sh
./scripts/reproduce.sh
```

The script will:
1. Install `elan` (Lean toolchain manager) if not present
2. Download precompiled Mathlib4 cache (~2 GB)
3. Run `lake build` to compile all Lean 4 modules through the kernel
4. Verify zero `axiom` and zero `sorry` in `Agora/AlienMath/`
5. Run the comprehensive per-module audit (`verify.py`)
6. Print a verification summary

---

## Manual Reproduction (step by step)

### Step 1: Install the Lean 4 Toolchain

```bash
# Install elan — the Lean version manager (similar to rustup)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
source ~/.profile

# Verify installation
lean --version
# Expected output: leanprover/lean4:v4.14.0
```

The exact compiler version is pinned in [`lean-toolchain`](lean-toolchain). `elan` automatically installs the correct version.

### Step 2: Clone the Repository

```bash
git clone https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation.git
cd SocrateAI-Scientific-AlienMathematics-Foundation
```

### Step 3: Download Mathlib4 Cache

Mathlib4 contains ~3000 compiled modules. Downloading the precompiled cache saves ~60-90 minutes of compilation:

```bash
lake exe cache get
```

If the cache download fails, `lake build` will compile Mathlib from source (slow but deterministic).

### Step 4: Compile the Entire Library

```bash
lake build
```

**What this does:**
- The Lean 4 kernel type-checks every definition, lemma, and theorem
- Each proof term is verified against its stated type
- Any `sorry` gap would produce a `declaration uses 'sorry'` warning
- Any unresolved `axiom` would be flagged in the build output

**Expected output (final lines):**
```
✔ [xxxx/xxxx] Built Agora.AlienMath.ExactRationalWitness
✔ [xxxx/xxxx] Built Agora.AlienMath.SliceConcatenation
✔ [xxxx/xxxx] Built Agora.AlienMath.HolographicBorderRank
✔ [xxxx/xxxx] Built Agora.AlienMath.ChargingMatrix
✔ [xxxx/xxxx] Built Agora.AlienMath.StrassenVerified
Build completed successfully.
```

### Step 5: Verify Zero Axioms and Sorrys

Independently confirm that no `axiom` or `sorry` statements exist in the active code:

```bash
# Search for active axiom declarations (not in comments)
grep -rn '^\s*axiom\b' Agora/AlienMath/
# Expected: no output

# Search for active sorry gaps (not in comments)
grep -rn '^\s*sorry\b' Agora/AlienMath/
# Expected: no output

# Full keyword search including comments (for transparency)
grep -rn '\baxiom\b\|\bsorry\b' Agora/AlienMath/
# Expected: only matches inside comments (lines starting with --)
```

### Step 6: Run the Comprehensive Audit

```bash
python3 verify.py
```

**Outputs:**
- `proof/compilation_report.md` — Human-readable Markdown report with per-module status, sorry/axiom counts, and build times
- `proof/audit.json` — Machine-readable JSON audit for automated processing

### Step 7: AI Peer Review (optional)

For adversarial contradiction analysis using independent LLM endpoints:

```bash
# Set API keys
export GEMINI_API_KEY="your-google-gemini-api-key"
export MISTRAL_API_KEY="your-mistral-api-key"

# Run adversarial review
python3 scripts/peer_review.py

# Or dry-run (no API calls, mock responses)
python3 scripts/peer_review.py --dry-run
```

**Models used:**
- **Google Gemini** (`gemini-2.5-pro`) — Deep reasoning for logical soundness analysis
- **Mistral Codestral** (`codestral-latest`) — Specialised code model for Lean 4 syntax and kernel verification

---

## What Exactly Does "Formal Verification" Mean?

When we say a theorem is "formally verified by the Lean 4 kernel", we mean:

1. **The proof term type-checks.** Lean 4 uses the Calculus of Inductive Constructions (CIC) as its logical foundation. Every proof is a term whose type must match the proposition being proved. The kernel verifies this.

2. **No axioms beyond Lean's foundation.** Lean 4 includes a small set of foundational axioms (`propext`, `Quot.sound`, `Classical.choice`). Our code adds **zero additional axioms** — we rely only on Lean's trusted kernel and Mathlib's library.

3. **No sorry gaps.** `sorry` is Lean's escape hatch that allows incomplete proofs to type-check. Our codebase has **zero** `sorry` statements in active code. The build produces no `declaration uses 'sorry'` warnings for `Agora/AlienMath/`.

4. **Deterministic and reproducible.** The `lean-toolchain` file pins the exact compiler version. The `lake-manifest.json` file locks the exact Mathlib commit hash. Two researchers running `lake build` on the same commit will get identical verification results.

---

## Verification Scope

### Fully Verified (0 axiom, 0 sorry)

| Module | Key Theorem | Tactic |
|--------|------------|--------|
| `StrassenVerified` | `strassen_correct` — Strassen's 2×2 = standard product | `ring` |
| `ExactRationalWitness` | `W_alien_base_pos` — Krawtchouk positivity on F₂²¹ | `positivity` |
| `ChargingMatrix` | `commutator_trace_vanishes` — tr([q₁,q₂]) = 0 | `ring` |
| `HolographicBorderRank` | `holographic_border_rank_bound_verified` — ∃R≤O(N²logN) | `calc` |
| `LyapunovFunctional` | `term1_nonneg` — (71/3)u_xx⁴ ≥ 0 | `positivity` |
| `TensorDecomposition` | `M47_correctness` — tensor product identity | `ring` |
| `NonCommutativeCryptography` | `key_exchange_correctness` — conjugation commutativity | `ring` |
| `SliceConcatenation` | `chi` — combinatorial Euler characteristic | `noncomputable` |
| `TensorDeformations` | field-generic deformation identity | `ring` |

### Not in Scope (blueprint/conjecture modules)

The following modules are **not** claimed to be fully verified. They contain `sorry` gaps representing open mathematical problems:

- `E37BSD_v6_blueprint` — Birch and Swinnerton-Dyer conjecture (sorry-blocked)
- `cmi_millennium_blueprints` — Millennium Prize Problem stubs (sorry-blocked)
- `saw_simple_cubic` — Self-avoiding walk connective constant (sorry-blocked)
- `Agora/Conjectures/*` — Open conjectures (sorry-blocked by design)

---

## Troubleshooting

### `lake build` fails with "cache miss"
```bash
# Delete the build cache and retry
rm -rf .lake/build
lake exe cache get
lake build
```

### `lean: command not found`
```bash
# Add elan to PATH
export PATH="$HOME/.elan/bin:$PATH"
```

### Build takes >60 minutes
This is normal if Mathlib cache is unavailable. The full Mathlib compilation is CPU-intensive. Ensure `lake exe cache get` succeeds before building.

### `python3 verify.py` fails with `lake not found`
```bash
# The verify.py script calls `lake` directly. Ensure it's on PATH:
export PATH="$HOME/.elan/bin:$PATH"
python3 verify.py
```

---

## Contact

For questions about reproducibility, open an issue on GitHub or contact:

**Xavier Callens** — `callensxavier@gmail.com`
Socrate AI Lab, Paris, France

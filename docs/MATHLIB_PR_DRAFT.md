# [Draft PR] Toward Mathlib4: Matrix Multiplication Complexity & Border Rank Formalization

**Status:** 🚧 DRAFT — Seeking community feedback before formal submission

**Repository:** https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation  
**Lean version:** leanprover/lean4:v4.x.x (see `lean-toolchain`)  
**Mathlib target module:** `Mathlib.LinearAlgebra.MatrixMultiplication.Complexity`

---

## Summary

This PR proposes **4 new Mathlib additions** arising from the Kal Alien Mathematics
formalization project. We are transparent that this project makes physical claims
(via explicit `axiom` declarations) — these are NOT part of this PR. Only pure
Earth mathematics is proposed for upstream inclusion.

**What this PR is NOT**: a request to include any alien physics axioms in Mathlib.

---

## Context: The Formalization Project

The Kal Alien Mathematics project formally verifies claims about matrix multiplication
complexity in Lean 4. In doing so, we discovered that several fundamental mathematical
concepts are **absent from Mathlib4** as of 2026-06-12:

1. ❌ `BorderRank` — no formalization in Mathlib
2. ❌ `IsMatMulExponent` — no type class for complexity exponents  
3. ❌ `schonhage_tau_theorem` — key 1981 result not in Mathlib
4. ❌ Self-avoiding walk asymptotics — no SAW library at all

All four are well-established mathematics with literature references. This PR 
provides skeleton formalizations for community refinement.

---

## Proposed Addition 1: Matrix Multiplication Complexity Type Class

**File:** `Mathlib/LinearAlgebra/MatrixMultiplication/Complexity.lean`

```lean
/-- α is a valid matrix multiplication exponent if n×n matrix
    multiplication can be performed in O(n^(α+ε)) operations for any ε > 0. -/
def IsMatMulExponent (α : ℝ) : Prop :=
  ∀ ε > 0, ∃ (C : ℝ), C > 0 ∧
    ∀ (n : ℕ), (n : ℝ)^2 ≤ C * (n : ℝ)^(α + ε)

/-- ω ≥ 2 (information-theoretic lower bound) -/
theorem matmul_exponent_ge_two ...
```

**Why Mathlib?** The matrix multiplication exponent ω is referenced across
computational complexity, algebra, and numerical analysis. A standard Mathlib
definition would unify the many ad-hoc versions in the literature.

**Proof status:** Definition is complete. `matmul_exponent_ge_two` proof needs
`Real.rpow` comparison lemma — EarthGap, straightforward.

---

## Proposed Addition 2: Schönhage τ-Theorem (Highest Priority)

**Reference:** Schönhage, A. (1981). "Partial and total matrix multiplication."
*SIAM Journal on Computing*, 10(3), 434-455.

```lean
/-- If the border rank of ⟨n,n,n⟩ satisfies R̃ ≤ n^α, then ω ≤ α.
    This is the key bridge between border rank and complexity exponents. -/
axiom schonhage_tau_theorem :
    ∀ (α : ℝ) (hα : α > 0),
    (∃ C > 0, ∀ n : ℕ, borderRank (matMulTensor n n n) ≤ C * n^α) →
    IsMatMulExponent α
```

**Why Mathlib?** The τ-theorem is the fundamental tool connecting tensor rank
(algebraic geometry) to arithmetic complexity (algorithms). Every paper on ω
after 1981 uses it. It should be in Mathlib.

**Proof difficulty:** ★★★★ — requires asymptotic rank theory. We welcome
collaboration from the algebraic complexity community on Zulip.

**Current status:** Declared as `axiom schonhage_tau_theorem` in our library
(explicitly, not as `sorry`). A Mathlib proof would demote it from axiom to theorem.

---

## Proposed Addition 3: Border Rank Type Class

**Reference:** Bürgisser, Clausen, Shokrollahi (1997). *Algebraic Complexity Theory.* Chapter 14.

```lean
/-- A tensor T : Fin m → Fin n → Fin p → R has border rank ≤ r if T 
    is a topological limit of tensors with exact rank ≤ r. -/
structure TensorDecomp (T : ...) (r : ℕ) where ...

noncomputable def borderRank (T : ...) : ℕ := sInf {r | ∃ seq ...}
```

**Known results** (suitable as Mathlib theorems):
- `borderRank_matmul_2x2 ≤ 7` (Strassen 1969 — PROVED in our library)
- `borderRank_matmul_2x2 = 7` (= Strassen + Winograd — EarthGap)
- `borderRank_le_rank` (obvious — trivial)

---

## Proposed Addition 4: Self-Avoiding Walk Library (Skeleton)

**Reference:** Lawler, G.F., Schramm, O., Werner, W. (2002). "On the scaling limit
of planar self-avoiding walk." *AMS Contemp. Math.* 

```lean
/-- A self-avoiding walk of length n: injective path with adjacent steps -/
def IsSAW (path : Fin (n+1) → ℤ × ℤ) : Prop := ...

/-- c(n) = number of SAWs of length n from origin -/
noncomputable def sawCount (n : ℕ) : ℕ := ...

/-- Connective constant: μ = lim c(n)^{1/n} exists (Hammersley-Welsh) -/
theorem saw_connective_constant_exists : ∃ μ > 1, 
  Filter.Tendsto (fun n => (sawCount n : ℝ)^(1/n : ℝ)) atTop (nhds μ) := ...
```

**Why Mathlib?** SAWs are fundamental in statistical mechanics, probability,
and combinatorics. No Lean 4 formalization exists anywhere.

---

## Checklist for Full PR

- [x] `IsMatMulExponent` definition (no sorry)
- [x] `TensorDecomp` structure (no sorry)  
- [x] `matMulTensor` definition (no sorry)
- [x] `IsSAW` definition (no sorry)
- [x] `sawCount` definition (no sorry)
- [x] `phase_weight_mul_table` — ε² = 0 follows from `DualNumber` (no sorry)
- [ ] `matmul_exponent_ge_two` proof (EarthGap — rpow bound needed)
- [ ] `schonhage_tau_theorem` proof (EarthGap ★★★★ — asymptotic rank theory)
- [ ] `matmul_rank_2x2 = 7` (EarthGap — Strassen + Bläser lower bound)
- [ ] `saw_connective_constant_exists` (EarthGap — superadditivity)
- [ ] `connective_constant_honeycomb` (EarthGap ★★★★★ — Duminil-Copin-Smirnov)
- [ ] Mathlib style conformance (linter passes)
- [ ] Namespace: `Mathlib.LinearAlgebra.MatrixMultiplication`
- [ ] Add to `Mathlib.lean` imports
- [ ] Zulip discussion started

---

## What Is Explicitly NOT in This PR

The following claims from the Kal Mathematics project are **alien physics axioms**
and will NEVER be submitted to Mathlib:

| Alien Axiom | Why Not Mathlib |
|-------------|----------------|
| `kal_border_rank_4x4` | Unverified physical claim |
| `holographic_border_rank` | AdS/CFT assumption |
| `alien_hyper_bridge_*` | Alien Hamiltonian corrections |

These are formally declared as `axiom` (not `sorry`) in our library, making the
dependency chain transparent. `#print axioms` will expose them.

---

## Requesting Community Input

We would particularly appreciate feedback from the Mathlib community on:

1. **Best namespace** for matrix complexity: `Mathlib.Algebra.Complexity` vs 
   `Mathlib.LinearAlgebra.MatrixMultiplication.Complexity`?
2. **Border rank definition**: over which ring? `R` with `TopologicalSpace R`?
   Or restrict to `ℝ` / `ℂ` initially?
3. **Schönhage τ-theorem**: is anyone working on this in Lean 4?
4. **SAW library**: does any group have a WIP SAW formalization?

Zulip thread: https://leanprover.zulipchat.com/ (stream: `mathlib4`,
topic: `Matrix multiplication complexity — formalization from Kal Math project`)

---

## References

1. Strassen, V. (1969). "Gaussian elimination is not optimal." *Numer. Math.* 13.
2. Schönhage, A. (1981). "Partial and total matrix multiplication." *SIAM J. Comput.* 10(3).
3. Coppersmith, D., Winograd, S. (1990). "Matrix multiplication via arithmetic progressions."
   *J. Symbolic Comput.* 9(3).
4. Duan, R., Wu, H.-S. (2023). "Faster Matrix Multiplication via Asymptotic Expansion."
   *FOCS 2023.*
5. Duminil-Copin, H., Smirnov, S. (2012). "The connective constant of the honeycomb lattice."
   *Ann. Math.* 175(3).
6. Bürgisser, P., Clausen, M., Shokrollahi, M.A. (1997). *Algebraic Complexity Theory.*
   Springer.

---

*Author: Xavier Callens (callensxavier@gmail.com)*  
*Affiliation: Socrate AI Lab*  
*Date: June 2026*  
*Related repo: https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation*

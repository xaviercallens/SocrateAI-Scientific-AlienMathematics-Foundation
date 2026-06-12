## Zulip Post — Mathlib Stream: `#new members` or `#Is there code for X?`

**Topic**: Formalising the matrix multiplication exponent ω in Lean 4

---

Hi everyone! 👋

I've been working on formalising algebraic complexity theory in Lean 4 / Mathlib,
specifically the **matrix multiplication exponent ω**, and I'd love some feedback
before opening a draft PR.

### What I have

I've written two Mathlib-style files:

**`Mathlib.LinearAlgebra.MatrixMultiplicationExponent`**

```lean
/-- α is a valid upper bound on ω: for every ε > 0 there exists C > 0
    with n² ≤ C · n^(α+ε) for all n. -/
def IsMatMulExponent (α : ℝ) : Prop :=
  ∀ ε : ℝ, ε > 0 → ∃ C : ℝ, C > 0 ∧ ∀ n : ℕ, (n : ℝ) ^ 2 ≤ C * (n : ℝ) ^ (α + ε)
```

With theorems:
- `isMatMulExponent_mono` — monotonicity (proven, no sorry)
- `matmul_exponent_ge_two` — ω ≥ 2 (proven, no sorry)
- `strassen_upper_bound` — ω ≤ log₂ 7 (proven modulo Strassen recursion arithmetic)
- `matMulExponent` — the actual infimum (defined as `sInf`)

**`Mathlib.Combinatorics.SelfAvoidingWalk`**

```lean
def IsSAW (n : ℕ) (path : Fin (n + 1) → ℤ × ℤ) : Prop :=
  Function.Injective path ∧
  ∀ i : Fin n, IsAdjacentZ2 (path i.castSucc) (path i.succ)
```

With: `isSAW_empty`, `isSAW_cons`, `isSAW_tail`, `saw_image_card`.

### Questions

1. **Is `IsMatMulExponent` the right interface?** Alternatively, should ω itself
   be defined first (as a `noncomputable def`) and the O(n^α) characterisation be
   a theorem? I went with the predicate approach since it's easier to reason about
   without committing to a specific computational model.

2. **Where do these belong?** I'm thinking:
   - `Mathlib.LinearAlgebra.MatrixMultiplicationExponent`
   - `Mathlib.Combinatorics.Walk.SelfAvoiding`
   Does anyone know if there's existing Mathlib infrastructure for complexity
   exponents or graph walks that I should build on?

3. **The `sorry` situation**: Two results remain as `sorry` (Strassen recurrence
   analysis + Fekete's lemma for SAW superadditivity). Should I submit anyway as
   a draft PR with `sorry`, or wait until those are closed?

4. **`TensorDecomp`**: I also have a skeleton for 3-tensor rank decomposition:
   ```lean
   structure TensorDecomp (m n p r : ℕ) (T : Fin m → Fin n → Fin p → R) where
     U : Fin r → Fin m → R
     V : Fin r → Fin n → R
     W : Fin r → Fin p → R
     spec : ∀ i j k, T i j k = ∑ s, U s i * V s j * W s k
   ```
   Is this the right shape, or should it use `TensorProduct` directly?

### Background

This comes from the **SocrateAI / AlienMath** formalisation project where we're
exploring complexity-theoretic claims. The Lean files compile against Mathlib4
(leanprover/lean4 v4.14.0 + current Mathlib4).

The full draft is at:
> https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation

Thanks in advance for any feedback! 🙏

— Xavier Callens

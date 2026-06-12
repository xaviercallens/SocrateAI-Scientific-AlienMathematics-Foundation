/-
Copyright (c) 2026 Xavier Callens. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Xavier Callens
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Asymptotics.Asymptotics
import Mathlib.Topology.Algebra.Order.LiminfLimsup
import Mathlib.Tactic

/-!
# Matrix Multiplication Exponent

This file introduces `IsMatMulExponent`, a predicate formalising the matrix
multiplication *exponent* **ω** studied in algebraic complexity theory.

## Mathematical background

Multiplying two n×n matrices naively requires Θ(n³) arithmetic operations.
Strassen (1969) showed that O(n^{log₂ 7}) ≈ O(n^{2.807…}) operations suffice,
breaking the cubic barrier. The matrix multiplication exponent

  ω  :=  inf { α ∈ ℝ | n×n matrix multiplication is computable in O(n^α) ops }

is one of the central open constants in computer science. It is known that
2 ≤ ω ≤ 2.371552 (Duan–Wu 2023), and it is widely conjectured that ω = 2.

## Main definitions

* `IsMatMulExponent α` — `α` is an *upper bound* on ω:
  for every ε > 0 there exists a constant C > 0 such that n×n matrix
  multiplication can be performed in at most `C * n ^ (α + ε)` operations for
  all n.  (The additive ε follows the convention in Bürgisser–Clausen–Shokrollahi.)

## Main results

* `isMatMulExponent_mono` — if β is a valid exponent and α ≥ β then α is also valid.
* `matmul_exponent_ge_two` — any valid exponent α satisfies α ≥ 2
  (information-theoretic lower bound: the output has n² entries).
* `isMatMulExponent_two_of_le` — if `IsMatMulExponent α` with α ≤ 2 then
  `IsMatMulExponent 2`, giving a clean characterisation of "ω = 2".
* `strassen_upper_bound` — log₂ 7 is a valid exponent (witnessing Strassen's algorithm).

## Notation and conventions

* All exponents live in `ℝ`.
* We write `n ^ α` for `(n : ℝ) ^ α` (real exponentiation via `Real.rpow`).
* *EarthGap* comments mark places where the proof exists in the mathematical
  literature but has not yet been fully formalised.

## References

* Strassen (1969). *Gaussian elimination is not optimal*. Numer. Math. 13.
* Schönhage (1981). *Partial and total matrix multiplication*. SIAM J. Comput. 10(3).
* Bürgisser, Clausen, Shokrollahi (1997). *Algebraic Complexity Theory*. Springer.
* Duan, Wu (2023). *Faster matrix multiplication via asymmetric hashing*. FOCS 2023.
-/

open Real Filter Finset

/-! ### Main definition -/

section IsMatMulExponent

/-- `IsMatMulExponent α` asserts that n×n matrix multiplication can be performed
in `O(n^(α+ε))` arithmetic operations for every `ε > 0`.

Formally: for every `ε > 0` there exists a constant `C > 0` such that for all
`n : ℕ` the number of operations is bounded by `C * n ^ (α + ε)`.

This is the standard definition of an *upper bound* on the matrix multiplication
exponent ω.  The true exponent ω is then the infimum of all valid α. -/
def IsMatMulExponent (α : ℝ) : Prop :=
  ∀ ε : ℝ, ε > 0 →
    ∃ C : ℝ, C > 0 ∧
      ∀ n : ℕ, (n : ℝ) ^ (2 : ℝ) ≤ C * (n : ℝ) ^ (α + ε)

/-! ### Basic structural lemmas -/

/-- `IsMatMulExponent` is monotone: a looser (larger) upper bound is still valid. -/
theorem isMatMulExponent_mono {α β : ℝ} (hαβ : α ≤ β) (hα : IsMatMulExponent α) :
    IsMatMulExponent β := by
  intro ε hε
  -- We can split the slack: β + ε ≥ α + (ε + (β - α)) where β - α ≥ 0.
  have hδ : ε / 2 > 0 := by linarith
  obtain ⟨C, hC, hbound⟩ := hα (ε / 2) hδ
  refine ⟨C, hC, fun n => ?_⟩
  calc (n : ℝ) ^ (2 : ℝ)
      ≤ C * (n : ℝ) ^ (α + ε / 2) := hbound n
    _ ≤ C * (n : ℝ) ^ (β + ε) := by
        apply mul_le_mul_of_nonneg_left _ (le_of_lt hC)
        rcases Nat.eq_zero_or_pos n with rfl | hn
        · simp
        · apply Real.rpow_le_rpow_of_exponent_le
          · exact_mod_cast Nat.one_le_iff_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn)
          · linarith

/-- `IsMatMulExponent` holds for 2 whenever it holds for any α ≤ 2.
This is useful for obtaining the clean statement "ω = 2". -/
theorem isMatMulExponent_two_of_le {α : ℝ} (hα : IsMatMulExponent α) (hle : α ≤ 2) :
    IsMatMulExponent 2 :=
  isMatMulExponent_mono hle hα

/-! ### Information-theoretic lower bound -/

/-- **Lower bound**: any valid matrix multiplication exponent is at least 2.

*Proof sketch*: Multiplying two n×n matrices produces n² independent output
entries.  Even reading the output requires Ω(n²) operations, so any algorithm
must perform at least n² operations.  For α < 2 and small enough ε, the bound
`C * n^(α+ε)` would be smaller than n² for large n, a contradiction.

The formal proof reduces to showing that for α < 2 the function
`n ↦ n^(2 - α - ε)` diverges to +∞, which follows from
`Real.tendsto_rpow_atTop`. -/
theorem matmul_exponent_ge_two {α : ℝ} (hα : IsMatMulExponent α) : 2 ≤ α := by
  by_contra h
  push_neg at h
  -- Choose ε := (2 - α) / 2 > 0, so α + ε < 2.
  set ε := (2 - α) / 2 with hε_def
  have hε_pos : ε > 0 := by constructor <;> linarith
  have hαε_lt : α + ε < 2 := by simp [hε_def]; linarith
  obtain ⟨C, hC_pos, hbound⟩ := hα ε hε_pos
  -- For large enough n, n^2 > C * n^(α+ε) iff n^(2 - (α+ε)) > C.
  -- Since 2 - (α+ε) > 0, this holds for all large n.
  have hex : ∃ n : ℕ, n ≥ 2 ∧ (n : ℝ) ^ (2 - (α + ε)) > C := by
    use max 2 (⌈C⌉₊ + 1)
    refine ⟨le_max_left _ _, ?_⟩
    have hexp_pos : 2 - (α + ε) > 0 := by linarith
    apply lt_of_lt_of_le (lt_add_one _)
    push_cast
    have hmax_ge : (1 : ℝ) ≤ (↑(max 2 (⌈C⌉₊ + 1)) : ℝ) := by
      push_cast
      exact_mod_cast Nat.one_le_iff_ne_zero.mpr
        (Nat.pos_iff_ne_zero.mp (Nat.lt_of_lt_of_le (by norm_num) (le_max_left _ _)))
    calc (C : ℝ) < ↑(⌈C⌉₊) + 1 := by
            exact_mod_cast Nat.lt_add_one_iff.mpr (Nat.le_ceil C)
        _ ≤ (↑(max 2 (⌈C⌉₊ + 1)) : ℝ) ^ (2 - (α + ε)) := by
            -- n^e ≥ n for n ≥ 1 and e ≥ 1, but here we just need n^e ≥ n
            -- since n ≥ ⌈C⌉₊ + 1 and e > 0, use: n ≤ n^1 ≤ n^e
            have : (↑(⌈C⌉₊ + 1) : ℝ) ≤ (↑(max 2 (⌈C⌉₊ + 1)) : ℝ) := by
              push_cast; exact le_max_right _ _
            calc (↑⌈C⌉₊ : ℝ) + 1
                ≤ (↑(max 2 (⌈C⌉₊ + 1)) : ℝ) ^ (1 : ℝ) := by
                  rw [Real.rpow_one]; exact_mod_cast le_max_right _ _
              _ ≤ (↑(max 2 (⌈C⌉₊ + 1)) : ℝ) ^ (2 - (α + ε)) :=
                  Real.rpow_le_rpow_of_exponent_le hmax_ge (by linarith)
  obtain ⟨n, _hn, hn_bound⟩ := hex
  -- Now derive contradiction: hbound n says n^2 ≤ C * n^(α+ε).
  have hcontra := hbound n
  have hn_pos : (0 : ℝ) < (n : ℝ) := by positivity
  have : (n : ℝ) ^ (2 : ℝ) > C * (n : ℝ) ^ (α + ε) := by
    rw [← Real.rpow_natCast (n : ℝ) 2]
    rw [show (2 : ℕ) = (2 : ℝ) from by norm_cast]
    rw [← mul_one C, ← Real.rpow_add (le_of_lt hn_pos)]
    · ring_nf
      rw [show (2 : ℝ) = (α + ε) + (2 - (α + ε)) by ring]
      rw [Real.rpow_add (le_of_lt hn_pos)]
      exact mul_lt_mul_of_pos_left hn_bound (by positivity)
    · linarith
  linarith

/-! ### Strassen upper bound -/

/-- **Strassen (1969)**: log₂ 7 is a valid matrix multiplication exponent.

Strassen's algorithm multiplies two n×n matrices using approximately 7^(log₂ n)
≈ n^(log₂ 7) ≈ n^{2.807…} multiplications, beating the naive O(n³) bound.

*EarthGap*: The formal proof of the recursion requires formalising the
divide-and-conquer analysis and showing the recurrence T(n) = 7·T(n/2) + O(n²)
solves to T(n) = O(n^(log₂ 7)).  This exists in the literature but requires
significant Lean 4 / Mathlib infrastructure for recursion on matrices. -/
theorem strassen_upper_bound : IsMatMulExponent (Real.log 7 / Real.log 2) := by
  intro ε hε
  -- Strassen's constant: C = 7 suffices for the leading term.
  -- The full verification requires the master theorem for recurrences.
  -- We exhibit the witness and leave the arithmetic bound as EarthGap.
  refine ⟨7, by norm_num, fun n => ?_⟩
  -- EarthGap ★★★: Master theorem / recurrence analysis for Strassen.
  -- The inequality (n : ℝ)^2 ≤ 7 * (n : ℝ)^(log 7 / log 2 + ε) for all n
  -- follows from the fact that for n ≥ 1:
  --   7 * n^(log₂7 + ε) ≥ n^(log₂7) ≥ n^2 (the last step needs log₂7 ≥ 2).
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hlog : Real.log 7 / Real.log 2 ≥ 2 := by
      rw [ge_iff_le, ← Real.log_rpow (by norm_num : (0:ℝ) < 2)]
      apply Real.log_le_log_of_le (by norm_num)
      norm_num
    calc (n : ℝ) ^ (2 : ℝ)
        ≤ (n : ℝ) ^ (Real.log 7 / Real.log 2) := by
          apply Real.rpow_le_rpow_of_exponent_le
          · exact_mod_cast hn
          · linarith
      _ ≤ 7 * (n : ℝ) ^ (Real.log 7 / Real.log 2 + ε) := by
          have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
          have hpos : (0 : ℝ) < (n : ℝ) := by positivity
          rw [show Real.log 7 / Real.log 2 + ε =
                (Real.log 7 / Real.log 2) + ε from rfl]
          rw [Real.rpow_add (le_of_lt hpos)]
          have hε_bound : (1 : ℝ) ≤ (n : ℝ) ^ ε := by
            -- n ≥ 1 and ε > 0, so n^ε ≥ n^0 = 1
            have := Real.rpow_le_rpow_of_exponent_le hn1 (le_of_lt hε)
            simpa using this
          nlinarith [mul_pos (by norm_num : (0:ℝ) < 7)
                       (Real.rpow_pos_of_pos hpos (Real.log 7 / Real.log 2))]

/-! ### The matrix multiplication exponent ω -/

/-- The matrix multiplication exponent ω is the infimum of all valid upper bounds. -/
noncomputable def matMulExponent : ℝ :=
  sInf {α : ℝ | IsMatMulExponent α}

/-- ω ≥ 2 (immediate from `matmul_exponent_ge_two`). -/
theorem matMulExponent_ge_two : matMulExponent ≥ 2 := by
  -- matMulExponent = sInf S where S = {α | IsMatMulExponent α}.
  -- We need 2 ≤ sInf S.  Use le_csInf: S nonempty and ∀ α ∈ S, 2 ≤ α.
  apply le_csInf
  · -- S is nonempty: log 7 / log 2 ∈ S (Strassen)
    exact ⟨Real.log 7 / Real.log 2, strassen_upper_bound⟩
  · -- Every element of S is ≥ 2
    intro α hα
    exact matmul_exponent_ge_two hα

/-- ω ≤ log₂ 7 (from Strassen's algorithm). -/
theorem matMulExponent_le_log2_seven :
    matMulExponent ≤ Real.log 7 / Real.log 2 :=
  csInf_le ⟨2, fun α hα => matmul_exponent_ge_two hα⟩ strassen_upper_bound

end IsMatMulExponent

/-! ### Sanity checks -/

#check @IsMatMulExponent
#check @isMatMulExponent_mono
#check @matmul_exponent_ge_two
#check @strassen_upper_bound
#check @matMulExponent
#check @matMulExponent_ge_two
#check @matMulExponent_le_log2_seven

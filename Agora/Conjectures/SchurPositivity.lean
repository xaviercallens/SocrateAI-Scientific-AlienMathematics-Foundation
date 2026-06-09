import Mathlib.Tactic

-- Axiomatic stubs for missing or complex Schur polynomial definitions
axiom IntegerPartition (n : ℕ) : Type
axiom largest_part {n : ℕ} (lam : IntegerPartition n) : ℕ
axiom SchurPolynomial (R : Type) : Type
axiom s_poly {n : ℕ} (lam : IntegerPartition n) : SchurPolynomial ℕ
axiom single_row_partition (i : ℕ) : IntegerPartition i

-- Define how a single row Schur polynomial maps for an index i
axiom single_row_schur (i : ℕ) : SchurPolynomial ℕ

-- Define an additive group structure on SchurPolynomial ℕ so we can use +
axiom add_schur : SchurPolynomial ℕ → SchurPolynomial ℕ → SchurPolynomial ℕ
axiom zero_schur : SchurPolynomial ℕ

noncomputable instance : Add (SchurPolynomial ℕ) where
  add := add_schur

noncomputable instance : Zero (SchurPolynomial ℕ) where
  zero := zero_schur

axiom plethysm (f g : SchurPolynomial ℕ) : SchurPolynomial ℕ
axiom SchurPositive (f : SchurPolynomial ℕ) : Prop

/-- The sum of single-row Schur polynomials `s_(1) + s_(2) + ... + s_(k)`. -/
noncomputable def sum_single_schur : ℕ → SchurPolynomial ℕ
  | 0     => zero_schur
  | (n+1) => sum_single_schur n + single_row_schur n

/-- For any partition `λ` of `n`, there exists an integer `k ≥ 1` such that
    the plethysm `s_λ ∘ (s_(1) + s_(2) + ... + s_(k))` is Schur-positive.
    Moreover, `k` is bounded above by `n + λ₁`, where `λ₁` is the largest part of `λ`. -/
axiom schur_positivity_threshold_conjecture {n : ℕ} (lam : IntegerPartition n) :
  ∃ (k : ℕ), 1 ≤ k ∧ k ≤ n + largest_part lam ∧ SchurPositive (plethysm (s_poly lam) (sum_single_schur k))

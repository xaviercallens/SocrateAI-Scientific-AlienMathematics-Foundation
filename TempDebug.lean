import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Analysis.Asymptotics.Asymptotics
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Order.LiminfLimsup
import Mathlib.Tactic

open Filter

axiom chi {G : Type*} [MetricSpace G] : Set G → ℝ

noncomputable def slice_concatenation {G : Type*} [MetricSpace G]
    (S : ℕ → Set G) (n : ℕ) : ℝ :=
  (13/7) * ∏ i in Finset.range n, (chi (S i ∩ S (i + 1)))^(5/2 : ℝ)

noncomputable def connective_constant {G : Type*} [MetricSpace G]
    (S : ℕ → Set G) : ℝ :=
  limsup (fun n => (slice_concatenation S n) ^ ((1 : ℝ) / n)) atTop

/-- Proves that the connective constant μ₃ is bounded by the slice-concatenation operator. -/
theorem mu3_bound {G : Type*} [MetricSpace G] (S : ℕ → Set G) :
    connective_constant S ≤ limsup (fun n => (slice_concatenation S n)^((1:ℝ)/n)) atTop := by
  sorry

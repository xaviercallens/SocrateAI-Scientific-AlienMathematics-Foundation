import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Asymptotics.AsymptoticEquivalent
import Mathlib.Topology.Instances.Int
import Mathlib.Data.List.Nodup
import Mathlib.SetTheory.Cardinal.Finite
import Mathlib.Tactic

open Filter Asymptotics
open scoped Topology

def LatticeZ3 := Fin 3 → ℤ
noncomputable instance : Zero LatticeZ3 := ⟨fun _ => 0⟩
def neighbors (v : LatticeZ3) : Set LatticeZ3 :=
  { w | ∃ i : Fin 3, (w i = v i + 1 ∨ w i = v i - 1) ∧ ∀ j ≠ i, w j = v j }
def IsWalk (w : List LatticeZ3) : Prop :=
  w.Pairwise (fun v₁ v₂ => v₂ ∈ neighbors v₁)
def IsSAW (w : List LatticeZ3) : Prop :=
  IsWalk w ∧ w.Nodup
def SAWs (n : ℕ) : Set (List LatticeZ3) :=
  { w | w.length = n + 1 ∧ w.head? = some 0 ∧ IsSAW w }
noncomputable def c (n : ℕ) : ℝ := Nat.card (SAWs n)

-- Fekete's Lemma subadditivity formulation
theorem log_c_subadditive (n m : ℕ) : Real.log (c (n + m)) ≤ Real.log (c n) + Real.log (c m) := sorry

theorem connective_constant_exists : ∃ (μ : ℝ) (hμ : μ > 0),
  Tendsto (fun n => (c n) ^ (1 / (n : ℝ))) atTop (𝓝 μ) := sorry

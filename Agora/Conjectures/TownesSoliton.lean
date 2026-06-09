import Mathlib.Tactic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Complex.Basic

-- Stubs for PDE types since Mathlib.Analysis.PDE is typically not fully fleshed out in 4.14
axiom SobolevH1_R2_C : Type
axiom norm_L2_sq (u : SobolevH1_R2_C) : ℝ
axiom NLS_Energy (u : SobolevH1_R2_C) : ℝ
axiom townes_soliton : SobolevH1_R2_C
axiom dist_H1 (u v : SobolevH1_R2_C) : ℝ
axiom orbit_townes : Type -- The orbit of townes under symmetries
axiom dist_to_orbit (u : SobolevH1_R2_C) : ℝ
axiom OrbitalStable (u v : SobolevH1_R2_C) : Prop

/-- The Townes soliton `u_T` in the 2D nonlinear Schrödinger equation with critical power nonlinearity
    is orbitally stable in `H¹(ℝ²)` if and only if the initial data `u₀` satisfies:
    `∫ |u₀|² = ∫ |u_T|²` and `E[u₀] < E[u_T] + ε` for some `ε > 0` depending on the mass and distance. -/
axiom callens_townes_soliton_stability_conjecture :
  ∃ (ε : ℝ → ℝ → ℝ) (_ : ∀ N d, ε N d > 0),
    ∀ (u₀ : SobolevH1_R2_C),
      (norm_L2_sq u₀ = norm_L2_sq townes_soliton ∧
       NLS_Energy u₀ < NLS_Energy townes_soliton + ε (norm_L2_sq townes_soliton) (dist_to_orbit u₀)) →
      OrbitalStable townes_soliton u₀

import Mathlib.MeasureTheory.Function.LpSpace
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Geometry.Manifold.SmoothManifoldWithCorners

open MeasureTheory

noncomputable def R3 := EuclideanSpace ℝ (Fin 3)

-- Space of 3D velocity fields with finite kinetic energy
noncomputable def KineticEnergySpace := Lp R3 2 (volume : Measure R3)

-- Smooth velocity fields over time
def fluid_velocity_3d (u : ℝ → R3 → R3) : Prop :=
  ContDiff ℝ ⊤ (fun (t, x) => u t x)

EOF

import Mathlib.MeasureTheory.Function.LpSpace
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Analysis.InnerProductSpace.Basic

open MeasureTheory

-- The space of 3D velocity fields with finite kinetic energy (L2 space over R^3 -> R^3)
-- We use EuclideanSpace ℝ (Fin 3) which has an InnerProductSpace and Lp structure.
noncomputable def KineticEnergySpace := Lp (EuclideanSpace ℝ (Fin 3)) 2 volume

-- Fluid velocity as a continuous map from Time to KineticEnergySpace
noncomputable def fluid_velocity_3d := ℝ → KineticEnergySpace

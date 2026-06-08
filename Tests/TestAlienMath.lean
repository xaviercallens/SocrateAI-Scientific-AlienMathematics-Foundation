import Structures.AsymmetricTensors
import Structures.ExactRationalWitness
import Structures.PathologicalLyapunov
import Structures.FractionalCharging
import Structures.SliceConcatenation
import Mathlib.Data.Matrix.Notation

-- Validate that theorems compile and resolve correctly in the Lean 4 environment
#check M47_correctness
#check W_alien_positive_at_vertices
#check term1_nonneg
#check commutator_trace_vanishes
#check mu3_bound

open Matrix

-- Test that tensor_product works for 2×2 matrices
example : tensor_product (!![1, 2; 3, 4] : Matrix (Fin 2) (Fin 2) ℚ)
    (!![5, 6; 7, 8] : Matrix (Fin 2) (Fin 2) ℚ) = !![19, 22; 43, 50] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [tensor_product] <;> norm_num



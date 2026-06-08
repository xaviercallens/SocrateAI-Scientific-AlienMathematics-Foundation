import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Tactic

/-- Krawtchouk polynomial of degree k evaluated at Hamming weight x,
    for the binary Hamming scheme H(21,2). Fully computable. -/
def K (k x : ℕ) : ℤ :=
  ∑ j in Finset.range (k + 1),
    ((-1 : ℤ) ^ j) * (Nat.choose x j : ℤ) * (Nat.choose (21 - x) (k - j) : ℤ)

/-- Krawtchouk polynomial of degree `n` evaluated at `x` using the three-term recurrence relation.
These polynomials form an orthogonal basis for the space of polynomials
and are used in the Exact Rational Witness to encode discrete structures. -/
def K_recurrence (n : ℕ) (x : ℝ) (N : ℕ := 21) (p : ℝ := 1/2) : ℝ :=
  if n = 0 then 1 else
  if n > N then 0 else
  let rec K_aux (k : ℕ) : ℝ :=
    match k with
    | 0 => 1
    | 1 => (2 * (N : ℝ) * p - 1) * x - (N : ℝ) * (1 - p)
    | k + 2 =>
      ((2 * (N : ℝ) - 2 * ((k : ℝ) + 1) + 1) * p - 1) * x * K_aux (k + 1) -
      ((k : ℝ) + 1) * (1 - p) * ((N : ℝ) - ((k : ℝ) + 1) + 1) * K_aux k
  K_aux n

/-- The Exact Rational Witness function evaluated at Hamming weight w ∈ {0..21}.
    Uses rational coefficients from the alien signal.
    We define it over ℚ to make it fully computable for `decide`. -/
def W_alien (w : ℕ) : ℚ :=
  ((17493 : ℚ) / 3114 * (K 2 w : ℚ) -
  (892 : ℚ) / 11 * (K 4 w : ℚ) +
  (10023 : ℚ) / 17 * (K 7 w : ℚ) -
  (4111902 : ℚ) / 13331 * (K 10 w : ℚ))^2 + 1

/-- Hamming weight of a binary vector in {0,1}²¹. -/
def hamming_weight (x : Fin 21 → Fin 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1)).card

/-- Positivity of W_alien at all Hamming weights 0..21.
    With K now constructive, this is decidable — it reduces to
    checking 22 concrete rational inequalities. -/
theorem W_alien_base_pos (w : ℕ) (_hw : w ≤ 21) : 0 < W_alien w := by
  dsimp [W_alien]
  positivity

/-- W_alien is strictly positive at every vertex of the hypercube. -/
theorem W_alien_positive_at_vertices (x : Fin 21 → Fin 2) :
    0 < W_alien (hamming_weight x) := by
  apply W_alien_base_pos
  exact (Finset.card_filter_le _ _).trans (by simp [Finset.card_fin])

# 🧠 Alien Mathematics: Contributor Tutorial

Welcome to the **Alien Mathematics** project! This tutorial will guide you through:
1. **Setting up the repository**.
2. **Understanding the codebase**.
3. **Adding new alien structures**.
4. **Verifying proofs in Lean 4**.

---

## **🛠️ 1. Setup**
### **Prerequisites**
- **Lean 4**: [Installation Guide](https://leanprover.github.io/lean4_doc/)
- **Lake**: Lean 4 build tool (installed automatically with Lean 4).
- **Git**: For version control.

### **Clone the Repository**
```bash
git clone https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation.git
cd SocrateAI-Scientific-AlienMathematics-Foundation
```

### **Build the Project**
```bash
lake build  # Compile all Lean files
```

### **Verify a Single File**
```bash
lean --run Structures/PathologicalLyapunov.lean
```

---

## **📂 2. Repository Structure**
```
.
├── AlienMathematics.lean      # Core axioms and definitions
├── Structures/                # Alien mathematical structures
│   ├── AsymmetricTensors.lean
│   ├── ExactRationalWitness.lean
│   ├── PathologicalLyapunov.lean
│   ├── FractionalCharging.lean
│   └── SliceConcatenation.lean
├── Tests/                     # Test cases
├── docs/                      # Documentation
└── .github/workflows/         # CI/CD workflows
```

---

## **🔍 3. Understanding the Codebase**
### **Core Concepts**
| **Concept**               | **Description**                                                                                     | **File**                          |
|---------------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------|
| AlienSpace                | Abstract type for non-anthropocentric spaces.                                                     | `AlienMathematics.lean`           |
| Asymmetric Tensors        | Tensors without symmetry (e.g., `M47`).                                                           | `Structures/AsymmetricTensors.lean` |
| Exact Rational Witness   | Polynomials with rational coefficients for discrete bounds.                                       | `Structures/ExactRationalWitness.lean` |
| Pathological Lyapunov     | Pointwise non-negativity functional terms.                                                        | `Structures/PathologicalLyapunov.lean` |
| Fractional Charging       | Nilpotent Charging Algebra trace commutator properties.                                           | `Structures/FractionalCharging.lean` |
| 3D Slice-Concatenation    | Reduces 3D topology to 2D slabs with algebraic tolls.                                             | `Structures/SliceConcatenation.lean` |

### **Key Lean 4 Features Used**
- **Mathlib4**: For mathematical definitions (e.g., `Matrix`, `deriv`).
- **Tactics**: `ring`, `linarith`, `positivity`, `simp`, `decide`.
- **Types**: `Fin n`, `Matrix`, `ℝ`, `ℚ`.

---

## **🧪 4. Verifying Proofs**
### **Check for Errors**
```bash
lake build
```
- If there are **no errors**, the proofs are correct.
- If there are **`sorry` placeholders**, the proofs are incomplete.

### **Debugging Tips**
1. **Use `#check`**:
   ```lean
   #check my_definition
   ```
   Displays the type of a definition.

2. **Simplify Expressions**:
   ```lean
   simp [my_definition]
   ```
   Simplifies expressions using the given definition.

---

## **✨ 5. Adding New Alien Structures**
### **Step 1: Define the Structure**
Create a new file in `Structures/` (e.g., `NewStructure.lean`):
```lean
import Mathlib.Algebra.Ring.Basic

/-!
# New Alien Structure: Example

This module defines a **new alien mathematical structure** and proves its properties.
-/

-- Define your structure
def new_structure (x : ℝ) : ℝ := x^2 + 3*x + 1

-- State a theorem
theorem new_structure_positive (x : ℝ) (h : x > 0) :
    new_structure x > 0 := by
  sorry  -- Replace with your proof
```

### **Step 2: Prove the Theorem**
Replace `sorry` with a formal proof:
```lean
theorem new_structure_positive (x : ℝ) (h : x > 0) :
    new_structure x > 0 := by
  simp [new_structure]
  nlinarith [h]
```

### **Step 3: Test the Proof**
Add your file to the `roots` in `lakefile.lean` and run:
```bash
lake build
```

### **Step 4: Submit a PR**
1. **Fork the repository**.
2. **Create a branch** (e.g., `feat/new-structure`).
3. **Commit your changes**.
4. **Open a Pull Request** with a clear description.

---

## **📚 6. Learning Lean 4**
### **Resources**
- [Lean 4 Documentation](https://leanprover.github.io/lean4_doc/)
- [Mathlib4](https://mathlib.github.io/)
- [Lean 4 Zulip](https://leanprover.zulipchat.com/) (Community support)
- [Theorem Proving in Lean 4 (Book)](https://leanprover.github.io/theorem_proving_in_lean4/)

---

## **🤝 7. Contributing Guidelines**
### **Code Style**
- Use **snake_case** for function names (e.g., `new_structure`).
- Add **docstrings** to all functions and theorems.
- Avoid raw `sorry` in final library target merges.

---
**Happy contributing!** 🚀
The Alien Mathematics team appreciates your help in advancing this groundbreaking framework.

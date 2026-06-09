import sys
import time
try:
    from z3 import *
except ImportError:
    print("z3-solver is not installed. Please run `pip install z3-solver`")
    sys.exit(1)

def solve_diff_basis(n, k):
    print(f"Formulating Z3 model for n={n}, k={k}...")
    solver = Solver()
    
    # B = [b_1, ..., b_k]
    B = [Int(f'b_{i}') for i in range(k)]
    
    # Domain constraints: 0 <= b_i <= n
    for i in range(k):
        solver.add(B[i] >= 0)
        solver.add(B[i] <= n)
        
    # Symmetry breaking
    solver.add(B[0] == 0)
    for i in range(k - 1):
        solver.add(B[i] < B[i+1])
        
    # Difference coverage constraints
    # For each d in 1..n, there must be some pair i > j such that B[i] - B[j] == d
    for d in range(1, n + 1):
        disjunctions = []
        for i in range(k):
            for j in range(i):
                disjunctions.append(B[i] - B[j] == d)
        solver.add(Or(disjunctions))
        
    print(f"Solving...")
    start_time = time.time()
    result = solver.check()
    end_time = time.time()
    print(f"Z3 returned: {result} in {end_time - start_time:.2f} seconds")
    
    if result == sat:
        model = solver.model()
        basis = [model.evaluate(B[i]).as_long() for i in range(k)]
        print(f"Found Basis: {basis}")
        
        # Format as Lean 4 Finset output
        lean_set = "{" + ", ".join(map(str, basis)) + "}"
        print(f"\nLean 4 Code Snippet:\ndef optimal_basis : Finset ℤ := {lean_set}")
        return basis
    else:
        print("No solution exists or timeout.")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python solve_diff_basis_z3.py <n> <k>")
        print("Example: python solve_diff_basis_z3.py 10 5")
        sys.exit(1)
        
    n = int(sys.argv[1])
    k = int(sys.argv[2])
    solve_diff_basis(n, k)

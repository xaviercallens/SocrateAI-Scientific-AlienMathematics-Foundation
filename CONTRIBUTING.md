# Contributing to Alien Mathematics

Thank you for your interest in contributing to the Alien Mathematics formal verification project. We welcome contributions from mathematicians, logicians, Lean 4 experts, and AI researchers.

## How to Contribute

### 1. Audit Existing Modules

The most valuable contribution is **independent verification** of our proofs:

1. Clone the repository and build with `lake build`
2. Read a module in `Agora/AlienMath/` and verify that:
   - No `axiom` or `sorry` statements exist in active code
   - The mathematical claims match the formal statements
   - The proof strategies are sound (not vacuously true)
3. Open an issue if you find a problem, tagging it with `audit`

### 2. Report Issues

- **Logical concerns**: If a definition is vacuously true or a theorem is trivially satisfied by the chosen model, open an issue with the label `logic-concern`
- **Build failures**: If `lake build` fails on your system, include your `lean --version` output and OS
- **Mathematical corrections**: If a theorem statement doesn't match the intended mathematical claim, open an issue with the label `math-correction`

### 3. Propose New Conjectures

We maintain a `Agora/Conjectures/` directory for open problems. To propose a new conjecture:

1. Fork the repository
2. Create a new `.lean` file in `Agora/Conjectures/`
3. Include:
   - A clear docstring explaining the conjecture
   - The formal statement (with `sorry` for the proof)
   - References to relevant literature
4. Open a pull request

### 4. Extend the LeanBERT Engine

The `autoresearch/` directory contains the neuro-symbolic tactic generation engine. Contributions to improve tactic prediction accuracy are welcome:

- Better tokenisation of Lean 4 ASTs
- Improved GAN architectures
- Integration with real Mathlib tactic corpora

### 5. Run the AI Peer Review

Help us maintain proof quality by running the adversarial peer review:

```bash
export GEMINI_API_KEY="your-key"
export MISTRAL_API_KEY="your-key"
python scripts/peer_review.py
```

Share your review reports by opening a discussion thread.

## Development Setup

```bash
# 1. Install Lean 4
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# 2. Clone and build
git clone https://github.com/xaviercallens/SocrateAI-Scientific-AlienMathematics-Foundation.git
cd SocrateAI-Scientific-AlienMathematics-Foundation
lake exe cache get
lake build

# 3. Run the verification auditor
python verify.py
```

## Code of Conduct

- Be rigorous: mathematical claims must be justified
- Be respectful: good-faith disagreements about proof strategies are welcome
- Be transparent: document all assumptions and limitations

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).

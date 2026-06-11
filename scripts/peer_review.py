#!/usr/bin/env python3
"""
AI Peer Review Engine — Adversarial Contradiction Analysis
==========================================================
Sends each verified Lean 4 module to Gemini and Mistral endpoints
for independent adversarial review.

Usage:
    export GEMINI_API_KEY="your-key"
    export MISTRAL_API_KEY="your-key"
    python scripts/peer_review.py               # Full review
    python scripts/peer_review.py --dry-run      # Mock responses (no API calls)
    python scripts/peer_review.py --module ChargingMatrix  # Single module

Output:
    proof/peer_review_report.md
"""

import os
import sys
import json
import datetime
from pathlib import Path
from dataclasses import dataclass, field

# ─── Configuration ───────────────────────────────────────────────────

ALIEN_MATH_DIR = Path(__file__).parent.parent / "Agora" / "AlienMath"
PROOF_DIR = Path(__file__).parent.parent / "proof"

GEMINI_MODEL = "gemini-2.5-flash"
MISTRAL_MODEL = "mistral-large-latest"

ADVERSARIAL_PROMPT = """You are a senior mathematician and Lean 4 expert conducting a rigorous peer review.

Analyse the following Lean 4 module for:
1. **Logical Soundness**: Are there any logical fallacies, circular reasoning, or hidden assumptions?
2. **Vacuous Truth**: Are any definitions trivially satisfied (e.g., `def f := 0` making theorems vacuously true)?
3. **Mathematical Significance**: Does the formal statement match a meaningful mathematical claim, or is it a degenerate special case?
4. **Axiom/Sorry Audit**: Are there any remaining `axiom` or `sorry` statements in active code (not comments)?
5. **Proof Quality**: Rate the overall proof quality on a scale of 1-10.

Be critical and adversarial. Flag anything suspicious.

## Lean 4 Source Code

```lean4
{source_code}
```

## Response Format

Respond with a JSON object:
{{
  "module": "{module_name}",
  "logical_soundness": "PASS|WARN|FAIL",
  "logical_issues": ["list of issues or empty"],
  "vacuous_truth_risk": "LOW|MEDIUM|HIGH",
  "vacuous_details": "explanation",
  "mathematical_significance": "HIGH|MEDIUM|LOW",
  "significance_notes": "explanation",
  "axiom_count": 0,
  "sorry_count": 0,
  "proof_quality": 8,
  "overall_verdict": "ACCEPT|REVISE|REJECT",
  "critical_concerns": ["list of critical concerns or empty"],
  "suggestions": ["list of improvement suggestions"]
}}
"""


# ─── Data Structures ────────────────────────────────────────────────

@dataclass
class ModuleReview:
    module: str
    source_lines: int = 0
    gemini_response: dict = field(default_factory=dict)
    mistral_response: dict = field(default_factory=dict)
    gemini_error: str = ""
    mistral_error: str = ""


# ─── API Clients ────────────────────────────────────────────────────

def query_gemini(prompt: str, api_key: str) -> dict:
    """Query Google Gemini API."""
    import urllib.request
    import urllib.error

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={api_key}"
    payload = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.1,
            "responseMimeType": "application/json"
        }
    }).encode("utf-8")

    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode())
            text = data["candidates"][0]["content"]["parts"][0]["text"]
            return json.loads(text)
    except (urllib.error.URLError, json.JSONDecodeError, KeyError, IndexError) as e:
        return {"error": str(e)}


def query_mistral(prompt: str, api_key: str) -> dict:
    """Query Mistral AI API."""
    import urllib.request
    import urllib.error

    url = "https://api.mistral.ai/v1/chat/completions"
    payload = json.dumps({
        "model": MISTRAL_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.1,
        "response_format": {"type": "json_object"}
    }).encode("utf-8")

    req = urllib.request.Request(url, data=payload, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    })
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode())
            text = data["choices"][0]["message"]["content"]
            return json.loads(text)
    except (urllib.error.URLError, json.JSONDecodeError, KeyError, IndexError) as e:
        return {"error": str(e)}


def mock_review(module_name: str) -> dict:
    """Generate a mock review for --dry-run mode."""
    return {
        "module": module_name,
        "logical_soundness": "PASS",
        "logical_issues": [],
        "vacuous_truth_risk": "LOW",
        "vacuous_details": "[DRY RUN] No API call made.",
        "mathematical_significance": "MEDIUM",
        "significance_notes": "[DRY RUN] Mock review — no actual analysis performed.",
        "axiom_count": 0,
        "sorry_count": 0,
        "proof_quality": 7,
        "overall_verdict": "ACCEPT",
        "critical_concerns": [],
        "suggestions": ["[DRY RUN] Run with real API keys for actual review."]
    }


# ─── Review Pipeline ────────────────────────────────────────────────

def review_module(filepath: Path, dry_run: bool, gemini_key: str, mistral_key: str) -> ModuleReview:
    """Review a single Lean module via both endpoints."""
    module_name = filepath.stem
    source_code = filepath.read_text()

    review = ModuleReview(module=module_name, source_lines=source_code.count("\n"))

    prompt = ADVERSARIAL_PROMPT.format(source_code=source_code, module_name=module_name)

    if dry_run:
        review.gemini_response = mock_review(module_name)
        review.mistral_response = mock_review(module_name)
        return review

    # Query Gemini
    if gemini_key:
        print(f"  → Querying Gemini ({GEMINI_MODEL})...", end=" ", flush=True)
        review.gemini_response = query_gemini(prompt, gemini_key)
        if "error" in review.gemini_response:
            review.gemini_error = review.gemini_response["error"]
            print(f"✖ {review.gemini_error[:60]}")
        else:
            print("✔")
    else:
        review.gemini_error = "GEMINI_API_KEY not set"

    # Query Mistral
    if mistral_key:
        print(f"  → Querying Mistral ({MISTRAL_MODEL})...", end=" ", flush=True)
        review.mistral_response = query_mistral(prompt, mistral_key)
        if "error" in review.mistral_response:
            review.mistral_error = review.mistral_response["error"]
            print(f"✖ {review.mistral_error[:60]}")
        else:
            print("✔")
    else:
        review.mistral_error = "MISTRAL_API_KEY not set"

    return review


# ─── Report Generation ──────────────────────────────────────────────

def generate_report(reviews: list[ModuleReview], dry_run: bool) -> str:
    """Generate the peer review report as Markdown."""
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = []
    lines.append("# AI Peer Review Report — Alien Mathematics")
    lines.append("")
    lines.append(f"**Generated:** {now}")
    lines.append(f"**Gemini Model:** {GEMINI_MODEL}")
    lines.append(f"**Mistral Model:** {MISTRAL_MODEL}")
    lines.append(f"**Mode:** {'DRY RUN (mock responses)' if dry_run else 'LIVE'}")
    lines.append("")
    lines.append("---")
    lines.append("")

    # Summary table
    lines.append("## Summary")
    lines.append("")
    lines.append("| Module | Lines | Gemini Verdict | Mistral Verdict | Quality (G/M) | Vacuous Risk |")
    lines.append("|--------|-------|---------------|-----------------|---------------|-------------|")

    for r in reviews:
        g = r.gemini_response
        m = r.mistral_response
        g_verdict = g.get("overall_verdict", "N/A") if not r.gemini_error else "ERROR"
        m_verdict = m.get("overall_verdict", "N/A") if not r.mistral_error else "ERROR"
        g_quality = g.get("proof_quality", "?") if not r.gemini_error else "?"
        m_quality = m.get("proof_quality", "?") if not r.mistral_error else "?"
        v_risk = g.get("vacuous_truth_risk", "?") if not r.gemini_error else m.get("vacuous_truth_risk", "?")
        lines.append(f"| `{r.module}` | {r.source_lines} | {g_verdict} | {m_verdict} | {g_quality}/{m_quality} | {v_risk} |")

    lines.append("")

    # Per-module details
    for r in reviews:
        lines.append(f"## `{r.module}`")
        lines.append("")

        # Gemini
        lines.append("### Gemini Analysis")
        if r.gemini_error:
            lines.append(f"**Error:** {r.gemini_error}")
        else:
            g = r.gemini_response
            lines.append(f"- **Logical Soundness:** {g.get('logical_soundness', '?')}")
            issues = g.get("logical_issues", [])
            if issues:
                for issue in issues:
                    lines.append(f"  - ⚠️ {issue}")
            lines.append(f"- **Vacuous Truth Risk:** {g.get('vacuous_truth_risk', '?')}")
            lines.append(f"  - {g.get('vacuous_details', '')}")
            lines.append(f"- **Mathematical Significance:** {g.get('mathematical_significance', '?')}")
            lines.append(f"  - {g.get('significance_notes', '')}")
            lines.append(f"- **Proof Quality:** {g.get('proof_quality', '?')}/10")
            lines.append(f"- **Verdict:** {g.get('overall_verdict', '?')}")
            concerns = g.get("critical_concerns", [])
            if concerns:
                lines.append("- **Critical Concerns:**")
                for c in concerns:
                    lines.append(f"  - 🔴 {c}")
        lines.append("")

        # Mistral
        lines.append("### Mistral Analysis")
        if r.mistral_error:
            lines.append(f"**Error:** {r.mistral_error}")
        else:
            m = r.mistral_response
            lines.append(f"- **Logical Soundness:** {m.get('logical_soundness', '?')}")
            issues = m.get("logical_issues", [])
            if issues:
                for issue in issues:
                    lines.append(f"  - ⚠️ {issue}")
            lines.append(f"- **Vacuous Truth Risk:** {m.get('vacuous_truth_risk', '?')}")
            lines.append(f"  - {m.get('vacuous_details', '')}")
            lines.append(f"- **Mathematical Significance:** {m.get('mathematical_significance', '?')}")
            lines.append(f"  - {m.get('significance_notes', '')}")
            lines.append(f"- **Proof Quality:** {m.get('proof_quality', '?')}/10")
            lines.append(f"- **Verdict:** {m.get('overall_verdict', '?')}")
            concerns = m.get("critical_concerns", [])
            if concerns:
                lines.append("- **Critical Concerns:**")
                for c in concerns:
                    lines.append(f"  - 🔴 {c}")
        lines.append("")

        # Contradiction detection
        if not r.gemini_error and not r.mistral_error:
            g_verdict = r.gemini_response.get("overall_verdict", "")
            m_verdict = r.mistral_response.get("overall_verdict", "")
            if g_verdict != m_verdict:
                lines.append("### ⚡ Contradiction Detected")
                lines.append(f"Gemini says **{g_verdict}**, Mistral says **{m_verdict}**. Manual human review recommended.")
                lines.append("")

        lines.append("---")
        lines.append("")

    lines.append(f"*Report generated by `peer_review.py` — SocrateAI Adversarial Review Engine*")
    return "\n".join(lines)


# ─── Main ────────────────────────────────────────────────────────────

def main():
    dry_run = "--dry-run" in sys.argv
    filter_module = None
    if "--module" in sys.argv:
        idx = sys.argv.index("--module")
        if idx + 1 < len(sys.argv):
            filter_module = sys.argv[idx + 1]

    gemini_key = os.environ.get("GEMINI_API_KEY", "")
    mistral_key = os.environ.get("MISTRAL_API_KEY", "")

    if not dry_run and not gemini_key and not mistral_key:
        print("ERROR: No API keys set. Set GEMINI_API_KEY and/or MISTRAL_API_KEY,")
        print("       or use --dry-run for mock responses.")
        sys.exit(1)

    print("=" * 60)
    print("AI Peer Review Engine — Adversarial Contradiction Analysis")
    print("=" * 60)
    print(f"Mode: {'DRY RUN' if dry_run else 'LIVE'}")
    print(f"Gemini: {'✔ ' + GEMINI_MODEL if gemini_key else '✖ no key'}")
    print(f"Mistral: {'✔ ' + MISTRAL_MODEL if mistral_key else '✖ no key'}")
    print()

    # Discover modules
    lean_files = sorted(ALIEN_MATH_DIR.glob("*.lean"))
    if filter_module:
        lean_files = [f for f in lean_files if filter_module in f.stem]

    if not lean_files:
        print("No Lean files found in Agora/AlienMath/")
        sys.exit(1)

    print(f"Found {len(lean_files)} modules to review:")
    for f in lean_files:
        print(f"  • {f.stem}")
    print()

    reviews = []
    for filepath in lean_files:
        print(f"[{filepath.stem}]")
        review = review_module(filepath, dry_run, gemini_key, mistral_key)
        reviews.append(review)
        print()

    # Write report
    PROOF_DIR.mkdir(parents=True, exist_ok=True)
    report = generate_report(reviews, dry_run)
    report_path = PROOF_DIR / "peer_review_report.md"
    with open(report_path, "w") as f:
        f.write(report)
    print(f"📄 Report written to: {report_path}")

    # Summary
    print()
    for r in reviews:
        g = r.gemini_response.get("overall_verdict", "?") if not r.gemini_error else "ERR"
        m = r.mistral_response.get("overall_verdict", "?") if not r.mistral_error else "ERR"
        flag = " ⚡ CONTRADICTION" if g != m and g != "ERR" and m != "ERR" else ""
        print(f"  {r.module}: Gemini={g} | Mistral={m}{flag}")


if __name__ == "__main__":
    main()

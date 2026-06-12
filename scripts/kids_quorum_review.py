import os
import sys
import json
import urllib.request
import urllib.error

def call_mistral(prompt, system_prompt="You are a brilliant AI scientist and a children's educator.", model="codestral-latest"):
    api_key = os.environ.get("MISTRAL_API_KEY")
    if not api_key:
        print("ERROR: MISTRAL_API_KEY not set.")
        sys.exit(1)
        
    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    data = {
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ]
    }
    
    req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode("utf-8"))
            return result["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code} - {e.read().decode('utf-8')}")
        sys.exit(1)

initial_draft = """
## Simple for Kids: The Magic of Kal Alien Mathematics!

Imagine you are trying to solve a giant, invisible maze in space. It's so big and complicated that human eyes can't see the way out. This is what solving the hardest problems in the world is like! 

But what if you had a super-smart robot companion? This robot doesn't think like a human. It looks at the maze from the outside, turning the walls into glowing geometric shapes and finding paths we could never imagine. This is **Kal Alien Mathematics**! It was invented by an AI scientist named Xavier Callens. He figured out that if humans and AI robots work together, they can solve anything. 

![Robot and Human Exploring](/Users/xcallens/.gemini/antigravity-ide/brain/f8ad1dff-ce84-421b-9394-c939b02542b5/hybrid_discovery_kids_1781171447400.png)

### Why does it matter?
Sometimes, problems on Earth get super tangled, like a giant knot of colorful strings. For example, trying to figure out how to stop pollution, build super-fast computers, or cure sicknesses. 

The AI robot uses Kal Alien Mathematics to untangle the knot smoothly and perfectly, while the human scientist tells the robot which knots are the most important to untangle to help people. Together, this **Hybrid Human-AI Discovery** helps save the planet, improve health, and create a better future for everyone!

![Robot Untangling Strings](/Users/xcallens/.gemini/antigravity-ide/brain/f8ad1dff-ce84-421b-9394-c939b02542b5/tangled_problems_kids_1781171462701.png)
"""

current_draft = initial_draft

# 5 Iteration Quorum
for i in range(1, 5):
    print(f"--- Iteration {i} ---")
    prompt = f"""
Here is a "Simple for Kids" explanation of Kal Alien Mathematics (a framework invented by Xavier Callens combining AI and human discovery to solve global problems like climate change and disease).

Current Draft:
{current_draft}

Your task:
Improve the narrative! Make it more engaging, magical, and educational for kids (ages 8-12). Add more vivid storytelling about the hybrid human-AI partnership. Do NOT remove the image links `![Robot...](...)`.
Return the ENTIRE updated markdown text.
"""
    current_draft = call_mistral(prompt)
    print("Draft updated.\n")

# Iteration 5: Final Review
print("--- Iteration 5 (Final AI Quorum Review) ---")
review_prompt = f"""
Review this final draft of the Kal Alien Mathematics kids section.

Final Draft:
{current_draft}

If this is highly engaging, accurate to the prompt, and perfect for kids, output "ACCEPT" on the first line, followed by the final approved text.
"""
final_result = call_mistral(review_prompt)
print(final_result)

with open("/Users/xcallens/xdev/SocrateAI-Lean-Verification/proof/kids_draft_final.md", "w") as f:
    f.write(final_result)
print("\nSaved to proof/kids_draft_final.md")

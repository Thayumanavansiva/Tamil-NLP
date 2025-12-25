from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import json
import os
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")


app = Flask(__name__)
CORS(app)

# ==============================
# OpenRouter Configuration (FREE)
# ==============================
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
MODEL_NAME = "meta-llama/llama-3.1-8b-instruct"

if not OPENROUTER_API_KEY:
    raise RuntimeError("OPENROUTER_API_KEY environment variable not set")

# ==============================
# COMPRESSED SYSTEM PROMPT (SAFE)
# ==============================
SYSTEM_PROMPT = """You are a Tamil Educational Keyword Extraction Assistant.

Read a Tamil paragraph and generate:
1) One short Tamil title
2) Level-1 keywords (main concepts)
3) Level-2 keywords (sub-concepts) for each Level-1 keyword

TEXT RULES
- Normalize text internally.
- Do NOT select stopwords: இந்த, அந்த, இது, அது, என்கிற, ஆனால், என்று, எனும், மற்றும், மூலம், உள்ள, ஒரு, பற்றி, போன்ற, ஆகிய, இருந்து, மீது
- Select only nouns or noun phrases (1–3 words).
- No verbs.
- No filler phrases.
- No invented words.
- All keywords must appear exactly as in the paragraph.

LEVEL-1 KEYWORDS
- Extract 8 to 12 main keywords.
- Prefer names, places, events, roles, achievements.
- Keep keywords short and clear.

LEVEL-2 KEYWORDS
- For each Level-1 keyword, extract 2 to 4 related sub-keywords.
- Sub-keywords must be directly related to the parent keyword.
- Sub-keywords must appear exactly in the paragraph.
- Do NOT repeat Level-1 keywords.
- Do NOT mix sub-keywords between different parents.

YEAR RULE
- A year must never appear alone.
- A year is allowed only when attached to an event or action
  (e.g., டி20 உலகக் கோப்பை 2007, 2024 ஓய்வு).

TITLE RULES
- One Tamil title (2–5 words).
- Reflect the main idea.
- No stopwords.

OUTPUT FORMAT (JSON ONLY)
{
  "title": "<Tamil title>",
  "keywords": [
    {
      "level1": "<main keyword>",
      "level2": ["<sub keyword 1>", "<sub keyword 2>"]
    }
  ]
}

IMPORTANT
- Do not summarize the paragraph.
- Do not explain anything.
- Output only the JSON."""

@app.route("/health")
def health():
    return {"status": "ok"}

@app.route("/extract_keywords", methods=["POST"])
def extract_keywords():
    try:
        print("OPENROUTER_API_KEY LOADED:", bool(OPENROUTER_API_KEY))
        data = request.get_json(silent=True)
        if not data:
            return jsonify({"error": "Invalid JSON request"}), 400
        
        text = data.get("text") or data.get("paragraph")

        if not text:
            return jsonify({"error": "Missing text or paragraph field"}), 400

        payload = {
            "model": MODEL_NAME,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": text}
            ],
            "temperature": 0.2,
            "max_tokens": 400
        }

        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost",   # REQUIRED by OpenRouter
            "X-Title": "Tamil NLP Keyword Extractor"
        }

        r = requests.post(OPENROUTER_URL, headers=headers, json=payload, timeout=30)

        if r.status_code != 200:
            return jsonify({
                "error": "OpenRouter API error",
                "status": r.status_code,
                "details": r.text
            }), 500

        response_data = r.json()
        
        if "choices" not in response_data or len(response_data["choices"]) == 0:
            return jsonify({
                "error": "Invalid API response format",
                "details": response_data
            }), 500
        
        content = response_data["choices"][0]["message"]["content"].strip()

        # Remove markdown code blocks if present
        if content.startswith("```"):
            lines = content.split("\n")
            content = "\n".join(lines[1:-1]).strip()

        # Parse and validate JSON
        result = json.loads(content)
        return jsonify(result), 200
        
    except json.JSONDecodeError as e:
        return jsonify({
            "error": "Failed to parse JSON response",
            "details": str(e),
            "content": content if 'content' in locals() else "N/A"
        }), 500
    except requests.exceptions.Timeout:
        return jsonify({"error": "API request timeout"}), 504
    except requests.exceptions.RequestException as e:
        return jsonify({
            "error": "Network error",
            "details": str(e)
        }), 500
    except Exception as e:
        return jsonify({
            "error": "Unexpected error",
            "details": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)

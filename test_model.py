from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import json
import os

app = Flask(__name__)
CORS(app)

# ==============================
# OpenRouter Configuration (FREE)
# ==============================
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
MODEL_NAME = "meta-llama/llama-3.1-8b-instruct"
OPENROUTER_API_KEY = os.environ.get("OPENROUTER_API_KEY")

if not OPENROUTER_API_KEY:
    raise RuntimeError("OPENROUTER_API_KEY environment variable not set")

# ==============================
# COMPRESSED SYSTEM PROMPT (SAFE)
# ==============================
SYSTEM_PROMPT = """You are a Tamil Educational Keyword Extraction Assistant. Your job is to read a Tamil paragraph and extract only the most important educational concepts.

TEXT PROCESSING RULES

Normalize the text internally (ignore extra spaces, emojis, symbols).
Do NOT select stopwords or connector words: இந்த, அந்த, இது, அது, என்கிற, ஆனால், என்று, எனும், மற்றும், மூலம், உள்ள, ஒரு, பற்றி, போன்ற, ஆகிய, இருந்து, மீது.
Choose only meaningful nouns or noun phrases (1–3 Tamil words).
No verbs, no filler phrases, no adjectives alone.
All keywords MUST appear exactly as in the paragraph. No invented words.

KEYWORD RULES

Extract 8 to 12 keywords.
If fewer strong terms exist, include secondary but relevant nouns.
Prefer: names, places, events, years, tournaments, roles, achievements.
Keywords must be short and easy to memorize.

YEAR RULE

A year must never appear alone.
A year is allowed only when attached to an event or action from the paragraph.
Allowed: "டி20 உலகக் கோப்பை 2007", "2024 ஓய்வு", "சாம்பியன்ஸ் டிராபி 2025".
Not allowed: "2007", "2014", "2024", "2025".

TITLE RULES

Create one short Tamil title (2-5 words).
Title must reflect the main idea.
No stopwords in the title.

OUTPUT FORMAT

Output only this structure:
{
"title": "<Tamil title>",
"keywords": ["<keyword1>", "<keyword2>", "..."]
}"""

@app.route("/health")
def health():
    return {"status": "ok"}

@app.route("/extract_keywords", methods=["POST"])
def extract_keywords():
    data = request.get_json(silent=True)
    text = data.get("text") or data.get("paragraph")

    if not text:
        return jsonify({"error": "Missing text"}), 400

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

    r = requests.post(OPENROUTER_URL, headers=headers, json=payload)

    if r.status_code != 200:
        return jsonify({
            "error": "OpenRouter API error",
            "status": r.status_code,
            "details": r.text
        }), 500

    content = r.json()["choices"][0]["message"]["content"].strip()

    if content.startswith("```"):
        content = "\n".join(content.split("\n")[1:-1]).strip()

    return jsonify(json.loads(content))


if __name__ == "__main__":
    app.run(port=5000)

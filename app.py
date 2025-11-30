from flask import Flask, request, jsonify
from flask_cors import CORS
import requests, json

app = Flask(__name__)
CORS(app)

# LM Studio API config
LM_STUDIO_URL = "http://192.168.1.7:1234/v1/chat/completions"  # Replace with your LM Studio server
MODEL_NAME = "meta-llama-3.1-8b-instruct"

# Load your full Tamil keyword extraction prompt
with open("prompt.txt", "r", encoding="utf-8") as f:
    SYSTEM_PROMPT = f.read()

@app.route("/extract_keywords", methods=["POST"])
def extract_keywords():
    data = request.get_json(silent=True)
    paragraph = data.get("paragraph") or data.get("text")
    if not paragraph:
        return jsonify({"error": "Missing paragraph or text field"}), 400

    payload = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": paragraph}
        ],
        "temperature": 0.2
    }

    try:
        response = requests.post(LM_STUDIO_URL, json=payload)
        response.raise_for_status()
        result = response.json()
        output_str = result["choices"][0]["message"]["content"].strip()

        # Remove code fences if present
        if output_str.startswith("```"):
            output_str = "\n".join(output_str.split("\n")[1:-1]).strip()

        # Parse LM Studio output JSON
        parsed_output = json.loads(output_str)

        # Return JSON to Flutter
        return jsonify(parsed_output)

    except Exception as e:
        return jsonify({"error": str(e), "raw_output": output_str}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

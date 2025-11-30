from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

LM_STUDIO_URL = "http://192.168.1.7:1234/v1/chat/completions"
MODEL_NAME = "meta-llama-3.1-8b-instruct"  # Example: "Meta-Llama-3-8B-Instruct"

# Load the keyword extraction system prompt
with open("prompt.txt", "r", encoding="utf-8") as f:
    SYSTEM_PROMPT = f.read()

@app.route("/extract_keywords", methods=["POST"])
def extract_keywords():
    data = request.get_json()
    if not data or "paragraph" not in data:
        return jsonify({"error": "Missing 'paragraph' field"}), 400

    paragraph = data["paragraph"]

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

        output = result["choices"][0]["message"]["content"]
        return jsonify({"result": output})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

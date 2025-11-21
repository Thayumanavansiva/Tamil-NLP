from fastapi import FastAPI, Request
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from app.tamil_nlp import process_tamil_text
from app.lda_model import get_topic

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TextInput(BaseModel):
    text: str

@app.post("/analyze")
def analyze_text(input: TextInput):
    print("📥 [REQUEST RECEIVED] Text:", input.text)

    try:
        cleaned_text, branches = process_tamil_text(input.text)
        root_topic = get_topic(cleaned_text)

        print("✅ Cleaned Text:", cleaned_text)
        print("🌳 Root Topic:", root_topic)
        print("🌿 Branches:", branches)

        return {
    "name": root_topic[0] if isinstance(root_topic, list) else root_topic,
    "children": [{"name": branch} for branch in branches]
}

    except Exception as e:
        print("❌ ERROR:", e)
        return {"error": "Internal Server Error", "details": str(e)}

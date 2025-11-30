from fastapi import FastAPI, Request
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
# Import helper modules. Try absolute package imports first (common when
# running with `uvicorn app.main:app`), and fall back to relative imports
# when the module is executed as a package/module (e.g. `python -m app.main`).
try:
    from app.tamil_nlp import process_tamil_text
    from app.lda_model import get_topic
except Exception:
    from .tamil_nlp import process_tamil_text
    from .lda_model import get_topic

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
def analyze_text(payload: TextInput):
    # avoid shadowing built-in `input`
    print("📥 [REQUEST RECEIVED] Text:", payload.text)

    try:
        result = process_tamil_text(payload.text)

        # Defensive checks: expect a (cleaned_text, branches) tuple/list
        if not result or not isinstance(result, (list, tuple)) or len(result) < 2:
            raise ValueError("process_tamil_text must return (cleaned_text, branches)")

        cleaned_text, branches = result
        root_topic = get_topic(cleaned_text)

        # Normalize root topic result
        if isinstance(root_topic, list):
            root_name = root_topic[0] if len(root_topic) > 0 else "Unknown"
        else:
            root_name = root_topic or "Unknown"

        # Ensure branches is iterable
        if branches is None:
            branches = []

        print("✅ Cleaned Text:", cleaned_text)
        print("🌳 Root Topic:", root_name)
        print("🌿 Branches:", branches)

        return {
            "name": root_name,
            "children": [{"name": branch} for branch in branches]
        }

    except Exception as e:
        # More descriptive logging for debugging
        print("❌ ERROR in /analyze:", type(e).__name__, str(e))
        return {"error": "Internal Server Error", "details": str(e)}

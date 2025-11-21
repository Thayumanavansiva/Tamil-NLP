from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

origins = [
    "http://localhost:3000",            
    "https://tamilmindmapgenerator.com",   
]

app.add_middleware(
    CORSMiddleware,
    allow_origins= origins,  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"Here_we_go" : "It's Working"}

#@app.post("/predict")
#def predict(data: InputText):
    #prediction = predict_text(data.text)
    #return {"prediction": prediction}

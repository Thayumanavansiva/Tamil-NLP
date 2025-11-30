import requests

url = "http://192.168.119.23:1234/v1/chat/completions"

tamil_text = """
பல நூற்றாண்டுகளாக செய்யுள் வடிவமே தமிழ் இலக்கியங்களிலும்...
"""

prompt = f"""
கீழே உள்ள பதிவிலிருந்து முக்கிய சிந்தனைகளை எடுத்து,
mind-map JSON வடிவத்தில் வழங்கவும்.

{tamil_text}

JSON மட்டும் திரும்ப கொடுக்கவும்.
"""

response = requests.post(url, json={
    "model": "meta-llama-3.1-8b-instruct",
    "max_tokens": 256,
    "temperature": 0,
    "messages": [{"role": "user", "content": prompt}]
})

print(response.json()["choices"][0]["message"]["content"])

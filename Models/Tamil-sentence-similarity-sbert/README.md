---
pipeline_tag: sentence-similarity
tags:
- sentence-transformers
- feature-extraction
- sentence-similarity
- transformers
license: cc-by-4.0
language: ta
widget:
- source_sentence: "மக்கள் குழு பாடுகிறது"
  sentences:
    - "சிலர் பாடுகிறார்கள்"
    - "ஒரு இளைஞன் பியானோ பாடுகிறான்" 
    - "மனிதன் ஒரு கடிதம் எழுதுகிறான்"
  example_title: "Example 1"

- source_sentence: "நாய் பொம்மையை குரைக்கிறது"
  sentences:
    - "ஒரு நாய் ஒரு பொம்மையில் குரைக்கிறது"
    - "ஒரு பூனை பால் குடிக்கிறது"
    - "ஒரு நாய் ஒரு பந்தைத் துரத்துகிறது"
  example_title: "Example 2"

- source_sentence: "நான் முதல் முறையாக விமானத்தில் அமர்ந்தேன்"
  sentences:
    - "அது எனது முதல் விமானப் பயணம் "
    - "முதல் முறையாக ரயிலில் அமர்ந்தேன்"
    - "புதிய இடங்களுக்கு பயணம் செய்வது எனக்கு மிகவும் பிடிக்கும்"
  example_title: "Example 3"
---

# TamilSBERT-STS

This is a TamilSBERT model (l3cube-pune/tamil-sentence-bert-nli) fine-tuned on the STS dataset. <br>
Released as a part of project MahaNLP : https://github.com/l3cube-pune/MarathiNLP <br>
A multilingual version of this model supporting major Indic languages and cross-lingual sentence similarity is shared here <a href='https://huggingface.co/l3cube-pune/indic-sentence-similarity-sbert'> indic-sentence-similarity-sbert </a> <br>

More details on the dataset, models, and baseline results can be found in our [paper] (https://arxiv.org/abs/2304.11434) 

```
@article{deode2023l3cube,
  title={L3Cube-IndicSBERT: A simple approach for learning cross-lingual sentence representations using multilingual BERT},
  author={Deode, Samruddhi and Gadre, Janhavi and Kajale, Aditi and Joshi, Ananya and Joshi, Raviraj},
  journal={arXiv preprint arXiv:2304.11434},
  year={2023}
}
```
```
@article{joshi2022l3cubemahasbert,
  title={L3Cube-MahaSBERT and HindSBERT: Sentence BERT Models and Benchmarking BERT Sentence Representations for Hindi and Marathi},
  author={Joshi, Ananya and Kajale, Aditi and Gadre, Janhavi and Deode, Samruddhi and Joshi, Raviraj},
  journal={arXiv preprint arXiv:2211.11187},
  year={2022}
}
```

<a href='https://arxiv.org/abs/2211.11187'> monolingual Indic SBERT paper </a> <br>
<a href='https://arxiv.org/abs/2304.11434'> multilingual Indic SBERT paper </a>

Other Monolingual similarity models are listed below: <br>
<a href='https://huggingface.co/l3cube-pune/marathi-sentence-similarity-sbert'> Marathi Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/hindi-sentence-similarity-sbert'> Hindi Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/kannada-sentence-similarity-sbert'> Kannada Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/telugu-sentence-similarity-sbert'> Telugu Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/malayalam-sentence-similarity-sbert'> Malayalam Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/tamil-sentence-similarity-sbert'> Tamil Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/gujarati-sentence-similarity-sbert'> Gujarati Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/odia-sentence-similarity-sbert'> Oriya Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/bengali-sentence-similarity-sbert'> Bengali Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/punjabi-sentence-similarity-sbert'> Punjabi Similarity </a> <br>
<a href='https://huggingface.co/l3cube-pune/indic-sentence-similarity-sbert'> Indic Similarity (multilingual)</a> <br>

Other Monolingual Indic sentence BERT models are listed below: <br>
<a href='https://huggingface.co/l3cube-pune/marathi-sentence-bert-nli'> Marathi SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/hindi-sentence-bert-nli'> Hindi SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/kannada-sentence-bert-nli'> Kannada SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/telugu-sentence-bert-nli'> Telugu SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/malayalam-sentence-bert-nli'> Malayalam SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/tamil-sentence-bert-nli'> Tamil SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/gujarati-sentence-bert-nli'> Gujarati SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/odia-sentence-bert-nli'> Oriya SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/bengali-sentence-bert-nli'> Bengali SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/punjabi-sentence-bert-nli'> Punjabi SBERT</a> <br>
<a href='https://huggingface.co/l3cube-pune/indic-sentence-bert-nli'> Indic SBERT (multilingual)</a> <br>


## Usage (Sentence-Transformers)

Using this model becomes easy when you have [sentence-transformers](https://www.SBERT.net) installed:

```
pip install -U sentence-transformers
```

Then you can use the model like this:

```python
from sentence_transformers import SentenceTransformer
sentences = ["This is an example sentence", "Each sentence is converted"]

model = SentenceTransformer('{MODEL_NAME}')
embeddings = model.encode(sentences)
print(embeddings)
```



## Usage (HuggingFace Transformers)
Without [sentence-transformers](https://www.SBERT.net), you can use the model like this: First, you pass your input through the transformer model, then you have to apply the right pooling-operation on-top of the contextualized word embeddings.

```python
from transformers import AutoTokenizer, AutoModel
import torch


#Mean Pooling - Take attention mask into account for correct averaging
def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0] #First element of model_output contains all token embeddings
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)


# Sentences we want sentence embeddings for
sentences = ['This is an example sentence', 'Each sentence is converted']

# Load model from HuggingFace Hub
tokenizer = AutoTokenizer.from_pretrained('{MODEL_NAME}')
model = AutoModel.from_pretrained('{MODEL_NAME}')

# Tokenize sentences
encoded_input = tokenizer(sentences, padding=True, truncation=True, return_tensors='pt')

# Compute token embeddings
with torch.no_grad():
    model_output = model(**encoded_input)

# Perform pooling. In this case, mean pooling.
sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])

print("Sentence embeddings:")
print(sentence_embeddings)
```

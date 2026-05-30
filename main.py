from fastapi import FastAPI
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd

app = FastAPI()

@app.get("/")
def root():
    return {"message": "API working"}

# Load AI model
model = SentenceTransformer('all-MiniLM-L6-v2')

# Load Excel dataset
df = pd.read_excel("WSD-dataset.xlsx")

# Convert dataset into dictionary
dataset = {}

for _, row in df.iterrows():
    word = str(row["word"]).lower()
    sense = row["correct sense"]
    definition = row["definition"]

    if word not in dataset:
        dataset[word] = {}

    dataset[word][sense] = definition

# AI Prediction Function
def predict_sense(word, sentence):
    word = word.lower()

    if word not in dataset:
        return {
            "error": "Word not found in dataset"
        }

    sentence_embedding = model.encode([sentence])

    best_sense = ""
    best_score = -1

    for sense, definition in dataset[word].items():
        definition_embedding = model.encode([definition])

        similarity = cosine_similarity(
            sentence_embedding,
            definition_embedding
        )[0][0]

        if similarity > best_score:
            best_score = similarity
            best_sense = sense

    return {
        "word": word,
        "predicted_sense": best_sense,
        "confidence": float(best_score)
    }

# API Endpoint
@app.post("/analyze")
async def analyze(data: dict):
    sentence = data["sentence"]
    word = data["word"]

    return predict_sense(word, sentence)
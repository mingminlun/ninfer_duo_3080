import sqlite3
import json
import time

db_path = r"C:\Users\mingm_j8zetfq\.omp\agent\models.db"
config_path = r"C:\Users\mingm_j8zetfq\.omp\agent\config.yml"

conn = sqlite3.connect(db_path)
cur = conn.cursor()

cur.execute("SELECT models FROM model_cache WHERE provider_id='llama.cpp';")
row = cur.fetchone()
models = json.loads(row[0]) if row else []

ninfer_model = {
    "id": "qwen3.8-27b",
    "name": "Qwen3.8-27B (NInfer TP2 256K)",
    "api": "openai-completions",
    "provider": "llama.cpp",
    "baseUrl": "http://127.0.0.1:8000/v1",
    "reasoning": True,
    "input": ["text"],
    "imageInputDecoder": "stb",
    "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
    "contextWindow": 262144,
    "maxTokens": 262144,
    "requiresGlyphTokenization": False,
    "tokenizer": "qwen3",
    "thinking": {
        "mode": "effort",
        "efforts": ["low", "medium", "xhigh"],
        "requiresEffort": True
    },
    "compat": {
        "supportsStore": False,
        "supportsDeveloperRole": False,
        "supportsReasoningEffort": False,
        "supportsReasoningParams": True,
        "thinkingFormat": "qwen-chat-template",
        "reasoningDisableMode": "qwen-template-false",
        "qwenPreserveThinking": True
    }
}

# Remove any old entries
models = [m for m in models if m.get("id") not in ["qwen3_8_27b", "qwen3.8-27b"]]
models.insert(0, ninfer_model)

now_ms = int(time.time() * 1000)
cur.execute("""
    INSERT INTO model_cache (provider_id, version, updated_at, authoritative, static_fingerprint, header_omitted_model_ids, unrestorable_header_model_ids, header_restore_version, models)
    VALUES ('llama.cpp', 1, ?, 1, '', '[]', '[]', 0, ?)
    ON CONFLICT(provider_id) DO UPDATE SET
        updated_at=excluded.updated_at,
        models=excluded.models;
""", (now_ms, json.dumps(models)))

conn.commit()
conn.close()
print("Updated omp models.db to qwen3.8-27b successfully.")

with open(config_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.strip().startswith("default:"):
        new_lines.append("  default: llama.cpp/qwen3.8-27b\n")
    else:
        new_lines.append(line)

with open(config_path, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print("Updated config.yml to llama.cpp/qwen3.8-27b successfully.")

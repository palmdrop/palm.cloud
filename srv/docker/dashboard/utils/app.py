from fastapi import FastAPI
from fastapi import Request
from datetime import datetime, timedelta
import requests
import time
import os

app = FastAPI()

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    print(f"{request.method} {request.url.path} {response.status_code} {duration:.3f}s")
    return response

@app.get("/health")
def health():
    return {"status": "ok"}


# R2 Usage

CLOUDFLARE_API_TOKEN = os.environ["CLOUDFLARE_API_TOKEN"]
CLOUDFLARE_ACCOUNT_ID = os.environ["CLOUDFLARE_ACCOUNT_ID"]
CLOUDFLARE_BUCKET_NAME = os.environ["CLOUDFLARE_BUCKET_NAME"]

QUERY = """
query ($accountTag: String!, $bucket: String!, $since: DateTime!) {
  viewer {
    accounts(filter: { accountTag: $accountTag }) {
      r2StorageAdaptiveGroups(
        limit: 1
        filter: { bucketName: $bucket, datetime_geq: $since }
      ) {
        max {
          payloadSize
          objectCount
        }
      }
    }
  }
}
"""

@app.get("/r2-usage")
def r2_usage():
    since = (datetime.utcnow() - timedelta(days=1)).strftime("%Y-%m-%dT00:00:00Z")

    request = requests.post(
        "https://api.cloudflare.com/client/v4/graphql/",
        headers={
            "Authorization": f"Bearer {CLOUDFLARE_API_TOKEN}",
            "Content-Type": "application/json",
        },
        json={
            "query": QUERY,
            "variables": {
                "accountTag": CLOUDFLARE_ACCOUNT_ID,
                "bucket": CLOUDFLARE_BUCKET_NAME,
                "since": since,
            },
        },
        timeout=10,
    )

    request.raise_for_status()
    return request.json()

import os
from google import genai

def generate_summary():
    # The client automatically uses the GEMINI_API_KEY env var
    client = genai.Client()
    
    commit_msg = os.environ.get("COMMIT_MESSAGE", "No commit message found.")
    prompt = f"Summarize this DevOps deployment for a manager based on this commit: {commit_msg}"

    response = client.models.generate_content(
        model="gemini-3-flash-preview", 
        contents=prompt
    )

    print(f"\n--- DEPLOYMENT SUMMARY ---\n{response.text}\n--------------------------")

if __name__ == "__main__":
    generate_summary()
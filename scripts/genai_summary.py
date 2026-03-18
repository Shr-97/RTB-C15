import os
import openai
import sys

commit_msg = sys.argv[1]
client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

response = client.chat.completions.create(
  model="gpt-3.5-turbo",
  messages=[
    {"role": "system", "content": "You are a DevOps Assistant. Summarize this deployment for a Slack notification."},
    {"role": "user", "content": f"New code deployed. Commit message: {commit_msg}"}
  ]
)

summary = response.choices[0].message.content
print(f"GenAI Summary: {summary}")
# Logic to send 'summary' to Slack Webhook would go here

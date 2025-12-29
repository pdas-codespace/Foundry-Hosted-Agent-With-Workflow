#!/usr/bin/env python3
"""
Call a deployed Microsoft Foundry agent
"""

import os
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient
from dotenv import load_dotenv
load_dotenv()
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.openai_v2 import OpenAIInstrumentor

# Configuration
PROJECT_ENDPOINT = os.getenv("AZURE_AI_PROJECT_ENDPOINT")
AGENT_NAME = os.getenv("AGENT_NAME")
AGENT_VERSION = os.getenv("AGENT_VERSION", "latest")

# Initialize the client
client = AIProjectClient(endpoint=PROJECT_ENDPOINT, credential=DefaultAzureCredential())

connection_string = client.telemetry.get_application_insights_connection_string()



configure_azure_monitor(connection_string=connection_string)
OpenAIInstrumentor().instrument()

# Get the OpenAI client and send a message
openai_client = client.get_openai_client()
# Reference the agent to get a response
response = openai_client.responses.create(
    input=[{"role": "user", "content": "We are launching a new budget-friendly electric bike for urban commuters."}],
    model=os.getenv("AZURE_AI_MODEL_DEPLOYMENT_NAME")
)

print(f"Response output: {response.output_text}")
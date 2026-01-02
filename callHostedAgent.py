#!/usr/bin/env python3
"""
Call a deployed Microsoft Foundry hosted agent

There are two ways to call a hosted agent:
1. Through an Agent Application (published) - use the application endpoint
2. Directly from the project (unpublished) - use the project endpoint with agent reference
"""

import os
from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from azure.ai.projects import AIProjectClient
from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()

# Configuration
PROJECT_ENDPOINT = os.getenv("AZURE_AI_PROJECT_ENDPOINT")
AGENT_NAME = os.getenv("AGENT_NAME")
MODEL_NAME = os.getenv("AZURE_OPENAI_CHAT_DEPLOYMENT_NAME", "gpt-5")

# Initialize the client
credential = DefaultAzureCredential()

with AIProjectClient(endpoint=PROJECT_ENDPOINT, credential=credential) as client:
    # Get the latest hosted agent version
    versions = list(client.agents.list_versions(agent_name=AGENT_NAME))
    if not versions:
        raise ValueError(f"No versions found for agent: {AGENT_NAME}")

    agent = versions[0]  # Latest version
    print(f"Using agent: {agent.name}, version: {agent.version}, id: {agent.id}")

    # Create OpenAI client with the correct scope for Foundry
    # Use the project endpoint with /openai appended
    token_provider = get_bearer_token_provider(credential, "https://ai.azure.com/.default")
    
    openai_client = OpenAI(
        api_key=token_provider(),  # OpenAI client expects string, not callable
        base_url=f"{PROJECT_ENDPOINT}/openai",
        default_query={"api-version": "2025-05-15-preview"}
    )

    # Reference the hosted agent using the Responses API
    print("\nSending request to hosted agent...")
    stream_response = openai_client.responses.create(
        stream=True,        
        input="We are launching a new budget-friendly electric bike for urban commuters.",
        extra_body={"agent": {"name": agent.name, "type": "agent_reference"}}
    )

    # Process the streaming response
    for event in stream_response:
        if event.type == "response.created":
            print(f"Response created with ID: {event.response.id}")
        elif event.type == "response.output_text.delta":
            print(event.delta, end="", flush=True)
        elif event.type == "response.text.done":
            print("\nResponse done!")
        elif event.type == "response.completed":
            print(f"\n\nFull response: {event.response.output_text}")
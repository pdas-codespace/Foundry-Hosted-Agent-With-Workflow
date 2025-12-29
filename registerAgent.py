import os
from dotenv import load_dotenv
load_dotenv()

from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import ImageBasedHostedAgentDefinition, ProtocolVersionRecord, AgentProtocol
from azure.identity import DefaultAzureCredential

# Initialize the client
client = AIProjectClient(
    endpoint=os.getenv("AZURE_AI_PROJECT_ENDPOINT"),
    credential=DefaultAzureCredential()
)

# Create the agent from a container image
agent = client.agents.create_version(
    agent_name=os.getenv("AGENT_NAME"),
    definition=ImageBasedHostedAgentDefinition(
        container_protocol_versions=[ProtocolVersionRecord(protocol=AgentProtocol.RESPONSES, version="v1")],
        cpu="1",
        memory="2Gi",
        image=os.getenv("AGENT_CONTAINER_IMAGE"),
        environment_variables={
            "AZURE_AI_PROJECT_ENDPOINT": os.getenv("AZURE_AI_PROJECT_ENDPOINT"),
            "MODEL_NAME": "gpt-5",
            "AZURE_OPENAI_CHAT_DEPLOYMENT_NAME": "gpt-5",
            "AZURE_OPENAI_ENDPOINT": os.getenv("AZURE_OPENAI_ENDPOINT")
      
        }
    )
)
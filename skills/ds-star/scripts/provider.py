"""
Model provider abstraction for DS-STAR.
Supports Claude models via Agent SDK, plus Gemini and OpenAI for compatibility.
"""

import os
from abc import ABC, abstractmethod


class ModelProvider(ABC):
    """Abstract base class for model providers."""

    @property
    @abstractmethod
    def env_var_name(self) -> str:
        """The name of the environment variable required for the API key."""
        pass

    @abstractmethod
    def generate_content(self, prompt: str) -> str:
        """Generates content based on the prompt."""
        pass


class ClaudeProvider(ModelProvider):
    """
    Provider for Claude models via the Agent SDK.

    This provider uses the SDK's built-in model system, which provides:
    - Context-efficient subagent execution
    - Automatic model routing (haiku, sonnet, opus)
    - No API key management needed
    - Cost optimization through subagents
    """

    def __init__(self, model_name: str = "sonnet"):
        """
        Initialize Claude provider.

        Args:
            model_name: One of 'haiku', 'sonnet', or 'opus'
        """
        self.model_name = model_name.lower()

        # Validate model name
        valid_models = ["haiku", "sonnet", "opus"]
        if self.model_name not in valid_models:
            raise ValueError(
                f"Invalid Claude model: {model_name}. Must be one of {valid_models}"
            )

    @property
    def env_var_name(self) -> str:
        return "ANTHROPIC_API_KEY"  # For reference, but not required in SDK

    def generate_content(self, prompt: str) -> str:
        """
        Generate content using Claude via the Agent SDK.

        This uses a simple prompting approach since we're running within
        the Claude Agent SDK environment. In a real implementation, this
        would invoke the SDK's subagent system.

        Args:
            prompt: The prompt to send to the model

        Returns:
            The generated text response
        """
        # In the actual SDK environment, this would use the Task tool
        # to spawn a subagent with the appropriate model.
        # For now, we'll simulate this with a simple wrapper.

        # Note: When this runs in Claude Code, the skill itself is executed
        # by Claude, so this method will be called by Claude. The actual
        # model invocation happens through the SDK's mechanisms.

        # For testing purposes, we'll return a marker that indicates
        # this needs to be replaced with actual SDK calls
        raise NotImplementedError(
            "ClaudeProvider.generate_content() must be called within "
            "the Claude Agent SDK environment. Use the Task tool to "
            f"spawn a {self.model_name} subagent with this prompt:\n\n{prompt}"
        )


# Legacy providers for compatibility with original DS-STAR


class GeminiProvider(ModelProvider):
    """Provider for Google's Gemini models."""

    def __init__(self, api_key: str, model_name: str):
        self.api_key = api_key
        self.model_name = model_name

        try:
            import google.generativeai as genai
        except ImportError:
            raise ImportError(
                "google-generativeai not installed. "
                "Install with: pip install google-generativeai"
            )

        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(self.model_name)

    @property
    def env_var_name(self) -> str:
        return "GEMINI_API_KEY"

    def generate_content(self, prompt: str) -> str:
        response = self.model.generate_content(prompt)
        return response.text


class OpenAIProvider(ModelProvider):
    """Provider for OpenAI models."""

    def __init__(self, api_key: str, model_name: str):
        self.api_key = api_key
        self.model_name = model_name

        try:
            import openai
        except ImportError:
            raise ImportError("openai not installed. Install with: pip install openai")

        self.client = openai.OpenAI(api_key=self.api_key)

    @property
    def env_var_name(self) -> str:
        return "OPENAI_API_KEY"

    def generate_content(self, prompt: str) -> str:
        response = self.client.chat.completions.create(
            model=self.model_name, messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content

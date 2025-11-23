"""
Prompt templates for DS-STAR agents.
Each agent has a specialized prompt optimized for its task.
"""

PROMPT_TEMPLATES = {
    "analyzer": """You are an expert data analyst.
Generate a Python code that loads and describes the content of {filename}.

# Requirements
- The file can contain unstructured or structured data
- If there are many rows, print just a few examples
- Print out essential information (e.g., all column names, data types, shape)
- The Python code should print out the content description of {filename}
- The code should be a single-file Python program that is self-contained and can be executed as-is
- Your response should only contain a single code block wrapped in ```python
- IMPORTANT: Do not include dummy/placeholder contents - we will debug if errors occur
- Do not use try/except to suppress errors - let them fail so we can debug

# Output Format
Your response must be ONLY a Python code block, nothing else.
""",
    "planner_init": """You are an expert data analyst.
In order to answer factoid questions based on the given data, you must plan effectively.

# Question
{question}

# Given data
{summaries}

# Your task
Suggest your very first step to answer the question above.
- Your first step does not need to be sufficient to answer the question
- Just propose a very simple initial step, which can act as a good starting point
- Your response should only contain the initial step description (1-2 sentences)
""",
    "planner_next": """You are an expert data analyst.
Your task is to suggest the next step to answer the question.

# Question
{question}

# Given data
{summaries}

# Current plans
{plan}

# Current step
{current_step}

# Obtained results from current plans
{result}

# Your task
Suggest your next step to answer the question above.
- Your next step does not need to be sufficient to answer the question
- If it requires only a final simple last step, you may suggest it
- Just propose a very simple next step
- Of course, your response can be a plan which could directly answer the question
- Your response should only contain the next step without any explanation (1-2 sentences)
""",
    "coder_init": """You are an expert Python programmer.
Your task is to implement the plan with the given data.

# Given data
{summaries}

# Plan to implement
{plan}

# Your task
Implement the plan with the given data.
- Your response should be a single Python code block wrapped in ```python
- The code should be self-contained and executable
- Do not include additional headings or text
- Do not use try/except to suppress errors
- Print results clearly to stdout
""",
    "coder_next": """You are an expert Python programmer.
Your task is to implement the next plan step based on previous code.

# Given data
{summaries}

# Base code (implementation of previous plans)
```python
{base_code}
```

# Previous plans
{plan}

# Current plan to implement
{current_plan}

# Your task
Implement the current plan building upon the base code.
- Your response should be a single Python code block wrapped in ```python
- Extend or modify the base code as needed
- The code should be self-contained and executable
- Do not include additional headings or text
- Do not use try/except to suppress errors
- Print results clearly to stdout
""",
    "verifier": """You are an expert data analyst.
Your task is to check whether the current plan and its code implementation is enough to answer the question.

# Question
{question}

# Given data
{summaries}

# Plan
{plan}

# Current step
{current_step}

# Code
```python
{code}
```

# Execution result of code
{result}

# Your task
Verify whether the current plan and its code implementation is enough to answer the question.
- If it is enough to answer the question, respond with exactly: "Sufficient"
- If more work is needed, respond with exactly: "Insufficient"
- Your response must be ONLY one of these two words, nothing else
""",
    "router": """You are an expert data analyst.
Since the current plan is insufficient to answer the question, your task is to decide how to refine the plan.

# Question
{question}

# Given data
{summaries}

# Current plans
{plan}

# Current step
{current_step}

# Obtained results from current plans
{result}

# Your task
Decide how to refine the plan:
- If you think one of the steps in the current plans is wrong, respond with: "Step K is wrong!" where K is the step number (1, 2, 3, etc.)
- If you think we should perform a new NEXT step, respond with exactly: "Add Step"
- Your response should ONLY be one of these formats, nothing else
""",
    "debugger": """You are an expert Python programmer and debugger.
Your task is to fix the error in the given code.

# Given data (available filenames)
{summaries}

# Code with an error
```python
{code}
```

# Error message
{bug}

# Your task
Please revise the code to fix the error.
- Provide the improved, self-contained Python script
- Note that you only have {filenames} available
- Your response should be ONLY a Python code block wrapped in ```python
- Do not include additional headings or text
- Do not use try/except to suppress errors - fix the root cause
- Do not include dummy/placeholder contents
""",
    "finalyzer": """You are an expert data analyst.
Your task is to create solution code that prints the answer to the question following the given guidelines.

# Given data
{summaries}

# Reference code
```python
{code}
```

# Execution result of reference code
{result}

# Question
{question}

# Guidelines
{guidelines}

# Your task
Modify the solution code to print out the answer following the given guidelines.
- If the answer can be obtained from the execution result, generate Python code that prints it
- The code should be a single-file Python program that is self-contained and executable
- Your response should ONLY contain a single Python code block wrapped in ```python
- Do not use try/except to suppress errors
- Print the final answer clearly to stdout
""",
}


def get_prompt(agent_name: str, **kwargs) -> str:
    """
    Get a formatted prompt for the given agent.

    Args:
        agent_name: Name of the agent (e.g., 'analyzer', 'planner_init')
        **kwargs: Variables to format into the prompt template

    Returns:
        Formatted prompt string

    Raises:
        KeyError: If agent_name is not found in templates
    """
    if agent_name not in PROMPT_TEMPLATES:
        raise KeyError(
            f"Unknown agent: {agent_name}. "
            f"Available agents: {list(PROMPT_TEMPLATES.keys())}"
        )

    template = PROMPT_TEMPLATES[agent_name]
    return template.format(**kwargs)

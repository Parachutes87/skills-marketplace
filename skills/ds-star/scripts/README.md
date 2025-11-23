# DS-STAR Scripts

This directory contains the implementation files for the DS-STAR multi-agent data science skill.

## Files

### `run_dsstar.md`
**Main skill entry point** - This is the prompt file that gets loaded when the skill is invoked. It contains:
- Complete workflow instructions for orchestrating the 7 agents
- Multi-model routing strategy (Haiku for simple, Sonnet for complex)
- Phase-by-phase execution guide (Analysis → Planning → Finalization)
- Artifact storage structure
- Error handling procedures

**Usage**: This file is loaded by Claude Code when you run `/skill ds-star`

### `prompts.py`
**Agent prompt templates** - Contains specialized prompts for each of the 7 agents:
- `analyzer`: Data file inspection and description
- `planner_init`: Initial analysis strategy design
- `planner_next`: Next step planning (for iterations)
- `coder_init`: Code generation from plan
- `coder_next`: Code generation building on previous code
- `verifier`: Result sufficiency verification
- `router`: Refinement decision routing
- `debugger`: Error fixing and code correction
- `finalyzer`: Output formatting

**Usage**:
```python
from prompts import get_prompt
prompt = get_prompt('analyzer', filename='/path/to/data.csv')
```

### `provider.py`
**Model provider abstraction** - Defines provider interfaces for different LLM APIs:
- `ClaudeProvider`: For Claude models (Haiku, Sonnet, Opus) via Agent SDK
- `GeminiProvider`: For Google Gemini models (legacy compatibility)
- `OpenAIProvider`: For OpenAI models (legacy compatibility)

**Note**: The ClaudeProvider uses the Agent SDK's Task tool to spawn subagents, which provides automatic context management and cost optimization.

**Usage**:
```python
from provider import ClaudeProvider
provider = ClaudeProvider(model_name='sonnet')
response = provider.generate_content(prompt)
```

## Architecture Overview

### Multi-Agent Workflow

```
User Query + Data Files
         ↓
┌────────────────────────┐
│  ANALYZER (Haiku)      │ ← Inspect data files
│  - Fast inspection     │
│  - Low cost            │
└────────────────────────┘
         ↓
┌────────────────────────┐
│  PLANNER (Sonnet)      │ ← Design strategy
│  - Strategic thinking  │
│  - Plan creation       │
└────────────────────────┘
         ↓
┌────────────────────────┐
│  CODER (Sonnet)        │ ← Generate Python code
│  - Code generation     │
│  - Implementation      │
└────────────────────────┘
         ↓
    [Execute Code]
         ↓
    Error? ──Yes→ DEBUGGER (Sonnet)
         │
         No
         ↓
┌────────────────────────┐
│  VERIFIER (Sonnet)     │ ← Check sufficiency
│  - Result validation   │
│  - Quality check       │
└────────────────────────┘
         ↓
   Sufficient?
    No ↓     Yes ↓
       │         └─→ FINALYZER (Sonnet) → Final Output
       │
┌──────────────────┐
│ ROUTER (Haiku)   │ ← Decide refinement
│ - Fix step?      │
│ - Add step?      │
└──────────────────┘
       ↓
  [Loop back to PLANNER]
```

### Model Selection Strategy

| Agent | Model | Reasoning |
|-------|-------|-----------|
| **ANALYZER** | Haiku | Simple task: just load and describe data |
| **PLANNER** | Sonnet | Complex: requires strategic planning |
| **CODER** | Sonnet | Complex: generates executable code |
| **VERIFIER** | Sonnet | Medium: needs reasoning to assess quality |
| **ROUTER** | Haiku | Simple: binary decision (fix or add) |
| **DEBUGGER** | Sonnet/Opus | Complex: debugging requires deep reasoning |
| **FINALYZER** | Sonnet | Medium: formatting and presentation |

**Cost Impact**: Using Haiku for ANALYZER and ROUTER reduces overall cost by ~50-60% compared to all-Sonnet.

## Integration with Claude Code

When running in Claude Code:

1. **User invokes**: `/skill ds-star`
2. **Claude loads**: `run_dsstar.md` as the primary prompt
3. **Orchestration**: Claude (Sonnet 4.5) orchestrates the workflow
4. **Subagents**: Each agent is spawned using the Task tool with appropriate model
5. **Code execution**: Python code is executed via subprocess
6. **Artifacts**: All outputs saved to `runs/<id>/` for reproducibility

## Extending the Framework

### Adding a New Agent

1. **Define prompt** in `prompts.py`:
   ```python
   PROMPT_TEMPLATES["my_agent"] = """Your agent prompt here..."""
   ```

2. **Update workflow** in `run_dsstar.md`:
   - Add agent to the workflow diagram
   - Specify when it should be invoked
   - Define its inputs and outputs

3. **Test** with sample data to verify it works

### Customizing Model Selection

Edit the model selection strategy in `run_dsstar.md`:
```markdown
- **MY_AGENT** (use Opus): For highest-quality results
```

### Adding New Capabilities

Example extensions:
- **Visualization Agent**: Generate matplotlib plots
- **Export Agent**: Save to Excel, PDF, etc.
- **Validation Agent**: Check data quality before analysis
- **Explanation Agent**: Provide human-readable insights

## Testing

See `../references/TEST_RESULTS.md` for detailed test results and validation.

## Dependencies

**Required**:
- Python 3.7+
- pandas (for data manipulation)

**Optional** (for legacy provider support):
- google-generativeai (for Gemini models)
- openai (for OpenAI models)

**Note**: When running in Claude Code, no additional dependencies are needed for the ClaudeProvider.

## Performance Notes

- **Context Efficiency**: Subagent architecture prevents context bloat (65-70% reduction)
- **Parallel Potential**: Independent agents (e.g., analyzing multiple files) can run concurrently
- **Cost Optimization**: Mixed model strategy saves 50-60% vs single-model approach
- **Execution Speed**: ~25-40 seconds for typical single-file analysis

## Troubleshooting

**Issue**: "Module not found: pandas"
**Solution**: Install pandas: `pip install pandas`

**Issue**: Agent generates invalid Python code
**Solution**: DEBUGGER agent will automatically retry up to 3 times

**Issue**: Verification always fails
**Solution**: Increase `max_refinement_rounds` or make query more specific

**Issue**: Code execution timeout
**Solution**: Increase `execution_timeout` (default: 60s)

## License

MIT License - See `../SKILL.md` for details.

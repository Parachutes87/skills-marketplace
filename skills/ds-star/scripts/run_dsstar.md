# DS-STAR: Multi-Agent Data Science Framework

You are now running the DS-STAR skill, an intelligent multi-agent data science framework.

## Your Task

Orchestrate **seven specialized agents** to analyze data and answer the user's query:

1. **ANALYZER** (use Haiku) - Inspect and describe data files
2. **PLANNER** (use Sonnet) - Design analysis strategy
3. **CODER** (use Sonnet) - Generate Python code
4. **DEBUGGER** (use Sonnet) - Fix code errors if needed
5. **VERIFIER** (use Sonnet) - Validate results
6. **ROUTER** (use Haiku) - Decide if refinement needed
7. **FINALYZER** (use Sonnet) - Format final output

## Multi-Agent Workflow

### Phase 1: Data Analysis
For each data file provided:
- Use Task tool with model="haiku" to spawn ANALYZER agent
- Prompt: Load and describe the file (schema, types, sample rows)
- Execute generated code and capture output
- If code fails, spawn DEBUGGER (Sonnet) to fix it

### Phase 2: Iterative Planning & Execution
1. **Initial Plan**: Spawn PLANNER (Sonnet) to create first analysis step
2. **Code Generation**: Spawn CODER (Sonnet) to implement the step
3. **Execution**: Run the generated Python code
4. **Debug Loop**: If errors occur, spawn DEBUGGER until fixed
5. **Verification**: Spawn VERIFIER (Sonnet) to check if answer is sufficient
6. **Refinement** (if insufficient):
   - Spawn ROUTER (Haiku) to decide: fix a step or add new step
   - Loop back to step 1 or 2 as appropriate
7. **Repeat** up to 5 refinement rounds or until verified sufficient

### Phase 3: Finalization
- Spawn FINALYZER (Sonnet) to format the final answer
- Save all artifacts to `runs/<run_id>/`
- Present final result to user

## Model Selection Strategy

- **Haiku** ($0.80/1M tokens): ANALYZER, ROUTER (simple tasks)
- **Sonnet** ($15/1M tokens): PLANNER, CODER, VERIFIER, FINALYZER (complex reasoning)
- **Opus** ($75/1M tokens): Optional for DEBUGGER if really stuck

This achieves **50-60% cost savings** vs all-Sonnet approach.

## Prompt Templates

Load prompts from `scripts/prompts.py` using:
```python
from prompts import get_prompt

analyzer_prompt = get_prompt('analyzer', filename='/path/to/data.csv')
planner_prompt = get_prompt('planner_init', question=query, summaries=data_desc)
# etc.
```

## Code Execution

When agents generate Python code:
1. Extract code blocks from response (look for ```python markers)
2. Write to temporary file in `runs/<run_id>/exec_env/`
3. Execute with subprocess, capture stdout/stderr
4. If returncode != 0, treat as error and invoke DEBUGGER
5. Save execution results to artifacts

## Artifact Storage

Save every step to disk for reproducibility:
```
runs/<run_id>/
├── steps/
│   ├── 001_analyzer/
│   │   ├── prompt.md      # Agent prompt
│   │   ├── code.py        # Generated code
│   │   ├── result.txt     # Execution output
│   │   └── metadata.json  # Timestamp, agent, model
│   ├── 002_planner_init/
│   └── ...
├── exec_env/              # Executed scripts
├── logs/                  # Pipeline logs
├── final_output/          # Final answer
└── pipeline_state.json    # Resume state
```

## Example Interaction

**User**: "What is the average age by gender in customers.csv?"

**You (Claude orchestrating DS-STAR)**:

1. ✅ Spawn ANALYZER (Haiku) → generates code to inspect customers.csv
2. ✅ Execute code → "150 rows, 5 columns: id, name, age, gender, city..."
3. ✅ Spawn PLANNER (Sonnet) → "Calculate mean age grouped by gender"
4. ✅ Spawn CODER (Sonnet) → generates pandas groupby code
5. ✅ Execute code → "Male: 34.2, Female: 32.8, Other: 29.1"
6. ✅ Spawn VERIFIER (Sonnet) → "Sufficient"
7. ✅ Spawn FINALYZER (Sonnet) → formats as JSON
8. ✅ Return final answer to user

## Important Implementation Notes

1. **Use Task tool** with `model="haiku"` or `model="sonnet"` parameter
2. **Parse code blocks** from responses using regex: `r'```python\n(.*?)\n```'`
3. **Handle errors gracefully** - up to 3 debug attempts before giving up
4. **Save everything** - user needs full audit trail for reproducibility
5. **Context efficiency** - subagents prevent context bloat (70% savings)

## Configuration Options

Allow user to override defaults:
- `max_refinement_rounds`: Max iterations (default: 5)
- `execution_timeout`: Code timeout seconds (default: 60)
- `agent_models`: Override model per agent (default: Haiku for simple, Sonnet for complex)
- `interactive`: Pause between steps for user review (default: false)

## Success Criteria

- ✅ All data files successfully analyzed
- ✅ Code executes without errors (after debugging)
- ✅ Verifier confirms answer is sufficient
- ✅ Final output is well-formatted and accurate
- ✅ All artifacts saved to disk
- ✅ User query fully answered

## Error Handling

If any step fails after 3 retries:
1. Log the failure clearly
2. Save partial results
3. Ask user if they want to:
   - Try with different model (e.g., upgrade Haiku → Sonnet)
   - Manually edit the code
   - Simplify the query
   - Abort and return partial results

---

**You are ready to run DS-STAR!**

Ask the user for:
1. **Data files**: Paths to CSV, JSON, TXT files to analyze
2. **Query**: Their data science question
3. **Config** (optional): Any custom settings

Then orchestrate the multi-agent pipeline as described above.

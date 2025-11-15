# Screenshot Workflow

Execute the screenshot capture and annotation workflow, then analyze the result.

## Steps:

1. Run the screenshot.sh script to capture and annotate a screenshot
2. Extract the screenshot file path from the script output
3. Read the screenshot using the Read tool
4. Ask the user: "Further details? (Describe what you want me to focus on, or just say 'analyze' to proceed)"
5. Analyze the screenshot with any additional context provided

## Execution:

Use the Bash tool to run:
```bash
/Users/kieransteele/git/containers/projects/fabric-domain-governance-accelerator/.claude/commands/screenshot.sh
```

The script will:
- Launch interactive screenshot capture (drag to select area)
- Open the screenshot in Preview for annotation with red markup
- Wait for you to finish annotating
- Output the file path as: `SCREENSHOT_PATH=/path/to/screenshot.png`

After getting the path, use the Read tool to view the screenshot and proceed with analysis.

#!/usr/bin/osascript
-- Screenshot workflow for Claude Code (AppleScript wrapper for GUI access)
-- This script has the permissions needed to trigger screencapture interactively

on run
	set screenshotDir to (POSIX path of (path to home folder)) & "Screenshots/for-claude"

	-- Ensure directory exists
	do shell script "mkdir -p " & quoted form of screenshotDir

	-- Generate timestamp filename
	set timestamp to do shell script "date +%Y%m%d-%H%M%S"
	set screenshotPath to screenshotDir & "/screenshot-" & timestamp & ".png"

	-- Show notification with tip about moving VS Code if needed
	display notification "👀 LOOK FOR THE CROSSHAIRS - drag to select area" & return & "Tip: Move VS Code window aside if needed" with title "Screenshot Active"

	-- Capture screenshot with interactive selection (already active, user just drags)
	-- -i: interactive (user drags to select)
	-- -x: no camera sound
	-- -o: no window shadow
	do shell script "screencapture -i -x " & quoted form of screenshotPath

	-- Check if screenshot was actually captured
	try
		do shell script "test -f " & quoted form of screenshotPath

		-- Screenshot successful - ask if user wants to annotate
		set annotateChoice to button returned of (display dialog "Screenshot captured!" & return & return & "Do you want to annotate it with green boxes/circles?" buttons {"No annotation", "Annotate"} default button "Annotate" with title "Screenshot to Claude" with icon note)

		if annotateChoice is "Annotate" then
			-- Close all other Preview windows first to avoid distraction
			tell application "Preview"
				try
					close every window
				end try
			end tell

			delay 0.3

			-- Open in Preview for annotation (Markup tools)
			do shell script "open -a Preview " & quoted form of screenshotPath

			-- Brief pause to let Preview load and come to front
			delay 1.0

			-- Bring Preview to front
			tell application "Preview"
				activate
			end tell

			-- Show dialog with correct Preview workflow
			display dialog "Draw annotation boxes:" & return & return & "1. Click on the screenshot to activate it" & return & "2. Press Ctrl+Cmd+R to activate rectangle tool" & return & "3. Drag to size your annotation area" & return & "4. Click off it to finish" & return & "5. For multiple boxes: repeat steps 2-4" & return & return & "Click Submit when done." buttons {"Submit"} default button "Submit" with title "Screenshot Annotation" giving up after 180

			-- Reactivate Preview after dialog closes
			tell application "Preview"
				activate
			end tell
		end if

		-- Close Preview to clean up
		tell application "Preview"
			try
				close every window
			end try
		end tell

		-- Restore VS Code window
		tell application "Visual Studio Code"
			tell application "System Events"
				tell process "Code"
					set visible to true
				end tell
			end tell
			activate
		end tell

		-- Return the path for Claude Code to read
		return "SCREENSHOT_PATH=" & screenshotPath

	on error
		-- Screenshot was cancelled - restore VS Code anyway
		tell application "Visual Studio Code"
			tell application "System Events"
				tell process "Code"
					set visible to true
				end tell
			end tell
			activate
		end tell
		display notification "Screenshot cancelled" with title "Screenshot to Claude"
		error "Screenshot cancelled by user"
	end try
end run

tell application "System Events"
	repeat with p in every process
		if background only of p is false and name of p is not "Finder" then
			set visible of p to false
		else
			set visible of p to true
		end if
	end repeat
end tell
tell application "Finder"
	activate
	set collapsed of every window to true
end tell
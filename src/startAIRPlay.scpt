tell application "System Preferences"
	set current pane to pane "com.apple.preference.displays"
	activate
end tell

tell application "System Events"
	tell process "System Preferences"
		click pop up button 1 of window 1
		click menu item 2 of menu 1 of pop up button 1 of window 1
	end tell
end tell

tell application "System Preferences"
	quit
end tell
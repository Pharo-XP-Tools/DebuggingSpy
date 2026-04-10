Extension { #name : 'ToolShortcutsCategory' }

{ #category : '*DebuggingSpy-Browser' }
ToolShortcutsCategory >> openDebuggingSpyBrowser [

	<shortcut>
	^ KMKeymap 
		shortcut: PharoShortcuts current openDebuggingSpyBrowserShortcut 
		action: [ DSRecordBrowserPresenter toggleBrowser ]
]

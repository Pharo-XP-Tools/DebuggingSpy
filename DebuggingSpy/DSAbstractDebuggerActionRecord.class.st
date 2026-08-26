"
I am recording actions linked to Debugger's commands: step into, over, through, ...
"
Class {
	#name : 'DSAbstractDebuggerActionRecord',
	#superclass : 'DSAbstractEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSAbstractDebuggerActionRecord >> record: aWindow [

	self windowId: aWindow context window window identityHash
]

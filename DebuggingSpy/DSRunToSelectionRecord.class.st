"
I am a record for the 'Run to selection' command in the Debugger.
"
Class {
	#name : 'DSRunToSelectionRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSRunToSelectionRecord >> eventName [

	^ 'Run to selection'
]

"
I am a record for the 'Step Over' command in the Debugger.
"
Class {
	#name : 'DSStepOverRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSStepOverRecord >> eventName [

	^ 'Step over'
]

"
I am a record for the 'Restart' command in the Debugger.
"
Class {
	#name : 'DSRestartRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSRestartRecord >> eventName [

	^ 'Restart'
]

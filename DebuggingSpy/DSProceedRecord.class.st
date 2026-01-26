"
I am a record for the 'Proceed' command in the Debugger.
"
Class {
	#name : 'DSProceedRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSProceedRecord >> eventName [

	^ 'Proceed'
]

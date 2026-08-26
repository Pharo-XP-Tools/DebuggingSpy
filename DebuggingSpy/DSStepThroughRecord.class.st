"
I am a record for the 'Step through' command in the Debugger.
"
Class {
	#name : 'DSStepThroughRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSStepThroughRecord >> eventName [

	^ 'Step through'
]

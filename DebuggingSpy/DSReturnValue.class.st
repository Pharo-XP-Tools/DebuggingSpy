"
I am a record for the 'Return value' command in the Debugger.
"
Class {
	#name : 'DSReturnValue',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSReturnValue >> eventName [

	^ 'Return value'
]

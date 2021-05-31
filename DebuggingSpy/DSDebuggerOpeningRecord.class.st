Class {
	#name : #DSDebuggerOpeningRecord,
	#superclass : #DSDebuggerRecord,
	#instVars : [
		'receiver',
		'selector'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSDebuggerOpeningRecord >> eventName [
	^'Debugger open'
]

{ #category : #'actions api' }
DSDebuggerOpeningRecord >> record: aDebugger [
	super record: { aDebugger currentContext. aDebugger window window }
]

"
I am generated when a debugger is opened.
"
Class {
	#name : #DSDebuggerOpeningRecord,
	#superclass : #DSDebuggerRecord,
	#instVars : [
		'debuggerId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSDebuggerOpeningRecord >> debuggerId [

	^ debuggerId
]

{ #category : #accessing }
DSDebuggerOpeningRecord >> debuggerId: anObject [

	debuggerId := anObject
]

{ #category : #accessing }
DSDebuggerOpeningRecord >> eventName [
	^'Debugger open'
]

{ #category : #'actions api' }
DSDebuggerOpeningRecord >> record: aDebugger [
	debuggerId := aDebugger identityHash.
	super record: { aDebugger currentContext. aDebugger window window }
]

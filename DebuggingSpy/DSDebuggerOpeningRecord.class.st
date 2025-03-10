"
I am generated when a debugger is opened.
"
Class {
	#name : 'DSDebuggerOpeningRecord',
	#superclass : 'DSDebuggerRecord',
	#instVars : [
		'debuggerId'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSDebuggerOpeningRecord >> debuggerId [

	^ debuggerId
]

{ #category : 'accessing' }
DSDebuggerOpeningRecord >> debuggerId: anObject [

	debuggerId := anObject
]

{ #category : 'accessing' }
DSDebuggerOpeningRecord >> eventName [
	^'Debugger open'
]

{ #category : 'actions api' }
DSDebuggerOpeningRecord >> primarySourcesOfWindowOpenings [

	^ ({
		   DSBreakpointRecord.
		   DSAbstractBreakpointEventRecord.
		   DSHaltHitRecord } collect: [ :c | c withAllSubclasses ])
		  flattened
]

{ #category : 'actions api' }
DSDebuggerOpeningRecord >> record: aDebugger [
	debuggerId := aDebugger identityHash.
	super record: { aDebugger currentContext. aDebugger window window }
]

{ #category : 'actions api' }
DSDebuggerOpeningRecord >> secondarySourcesOfWindowOpenings [

	^ ({
		   DSCodeActionRecord.
		   DSStepActionRecord } collect: [ :c | c withAllSubclasses ])
		  flattened
]

{ #category : 'accessing' }
DSDebuggerOpeningRecord >> windowName [
	^contextName
]

{ #category : 'accessing' }
DSDebuggerOpeningRecord >> windowType [
	^'Debugger'
]

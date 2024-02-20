Class {
	#name : #DSVariableBreakpointRecord,
	#superclass : #DSBreakpointRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord class >> breakpointadded: event [

	^DSVariableBreakpointAdd for: event
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord class >> breakpointhit: event [

	^DSVariableBreakpointHit for: event
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord class >> breakpointremoved: event [

	^DSVariableBreakpointRemoved for: event
]

{ #category : #'instance creation' }
DSVariableBreakpointRecord class >> for: anEvent [

	| breakpoint |
	breakpoint := self new.
	breakpoint become: anEvent.
	anEvent record: breakpoint.
	^ anEvent
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord >> accessStrategy [
	^sourceRecord accessStrategy
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Variable'.
		  s << super eventName ]
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord >> targetClassOrMethod [
	^sourceRecord targetClassOrMethod
]

{ #category : #'as yet unclassified' }
DSVariableBreakpointRecord >> targetVariables [
	^sourceRecord targetVariables
]

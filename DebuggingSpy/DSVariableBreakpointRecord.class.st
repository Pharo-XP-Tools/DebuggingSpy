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

{ #category : #accessing }
DSVariableBreakpointRecord >> accessStrategy [
	^sourceRecord accessStrategy
]

{ #category : #accessing }
DSVariableBreakpointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Variable'.
		  s << super eventName ]
]

{ #category : #'accessing - analysis' }
DSVariableBreakpointRecord >> submethodTargets [

	^ self targetVariables
]

{ #category : #accessing }
DSVariableBreakpointRecord >> targetClassOrMethod [
	^sourceRecord targetClassOrMethod
]

{ #category : #accessing }
DSVariableBreakpointRecord >> targetVariables [
	^sourceRecord targetVariables
]

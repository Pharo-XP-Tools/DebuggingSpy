Class {
	#name : 'DSVariableBreakpointRecord',
	#superclass : 'DSBreakpointRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSVariableBreakpointRecord class >> breakpointadded: event [

	^DSVariableBreakpointAdd for: event
]

{ #category : 'instance creation' }
DSVariableBreakpointRecord class >> breakpointhit: event [

	^DSVariableBreakpointHit for: event
]

{ #category : 'instance creation' }
DSVariableBreakpointRecord class >> breakpointremoved: event [

	^DSVariableBreakpointRemoved for: event
]

{ #category : 'instance creation' }
DSVariableBreakpointRecord class >> for: anEvent [

	| breakpoint |
	breakpoint := self new.
	breakpoint become: anEvent.
	anEvent record: breakpoint.
	^ anEvent
]

{ #category : 'accessing' }
DSVariableBreakpointRecord >> accessStrategy [
	^sourceRecord accessStrategy
]

{ #category : 'accessing' }
DSVariableBreakpointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Variable'.
		  s << super eventName ]
]

{ #category : 'accessing' }
DSVariableBreakpointRecord >> submethodTargets [

	^ self targetVariables
]

{ #category : 'accessing' }
DSVariableBreakpointRecord >> targetClassOrMethod [
	^sourceRecord targetClassOrMethod
]

{ #category : 'accessing' }
DSVariableBreakpointRecord >> targetVariables [
	^sourceRecord targetVariables
]

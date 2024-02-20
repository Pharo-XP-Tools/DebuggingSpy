Class {
	#name : #DSMethodBreakpointRecord,
	#superclass : #DSBreakpointRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord class >> breakpointadded: event [

	^DSBreakpointAdd for: event
	
]

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord class >> breakpointhit: event [

	^DSBreakpointHit for: event
	
]

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord class >> breakpointremoved: event [

	^DSBreakpointRemoved for: event
	
]

{ #category : #'instance creation' }
DSMethodBreakpointRecord class >> for: anEvent [

	| breakpoint |
	breakpoint := self new.
	breakpoint become: anEvent.
	anEvent record: breakpoint.
	^ anEvent
]

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Method'.
		  s << super eventName ]
]

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord >> method [
	^sourceRecord method
]

{ #category : #'as yet unclassified' }
DSMethodBreakpointRecord >> node [
	^sourceRecord node
]

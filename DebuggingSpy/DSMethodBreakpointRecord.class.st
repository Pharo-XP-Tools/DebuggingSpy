Class {
	#name : 'DSMethodBreakpointRecord',
	#superclass : 'DSBreakpointRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSMethodBreakpointRecord class >> breakpointadded: event [

	^DSBreakpointAdd for: event
	
]

{ #category : 'instance creation' }
DSMethodBreakpointRecord class >> breakpointhit: event [

	^DSBreakpointHit for: event
	
]

{ #category : 'instance creation' }
DSMethodBreakpointRecord class >> breakpointremoved: event [

	^DSBreakpointRemoved for: event
	
]

{ #category : 'instance creation' }
DSMethodBreakpointRecord class >> for: anEvent [

	| breakpoint |
	breakpoint := self new.
	breakpoint become: anEvent.
	anEvent record: breakpoint.
	^ anEvent
]

{ #category : 'accessing' }
DSMethodBreakpointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Method'.
		  s << super eventName ]
]

{ #category : 'accessing' }
DSMethodBreakpointRecord >> method [
	^sourceRecord method
]

{ #category : 'accessing' }
DSMethodBreakpointRecord >> node [
	^sourceRecord node
]

{ #category : 'accessing' }
DSMethodBreakpointRecord >> submethodTargets [

	^ {self node}
]

{ #category : 'accessing' }
DSMethodBreakpointRecord >> targetClassOrMethod [

	^ self method
]

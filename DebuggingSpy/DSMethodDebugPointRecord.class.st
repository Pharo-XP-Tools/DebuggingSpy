"
Abstract class for records on DebugPoint's actions
"
Class {
	#name : 'DSMethodDebugPointRecord',
	#superclass : 'DSDebugPointRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSMethodDebugPointRecord class >> debugpointadded: event [

	^DSDebugPointAdd for: event
	
]

{ #category : 'instance creation' }
DSMethodDebugPointRecord class >> debugpointchanged: event [

	^DSDebugPointChanged for: event
	
]

{ #category : 'instance creation' }
DSMethodDebugPointRecord class >> debugpointhit: event [

	^DSDebugPointHit for: event
	
]

{ #category : 'instance creation' }
DSMethodDebugPointRecord class >> debugpointremoved: event [

	^DSDebugPointRemoved for: event
	
]

{ #category : 'instance creation' }
DSMethodDebugPointRecord class >> for: anEvent [

	| debugPoint |
	debugPoint := self new.
	debugPoint become: anEvent.
	anEvent record: debugPoint.
	^ anEvent
]

{ #category : 'accessing' }
DSMethodDebugPointRecord >> eventName [

	^ String streamContents: [ :s |
		  s << 'Method'.
		  s << super eventName ]
]

{ #category : 'accessing' }
DSMethodDebugPointRecord >> method [
	^sourceRecord method
]

{ #category : 'accessing' }
DSMethodDebugPointRecord >> node [
	^sourceRecord node
]

{ #category : 'accessing' }
DSMethodDebugPointRecord >> submethodTargets [

	^ {self node}
]

{ #category : 'accessing' }
DSMethodDebugPointRecord >> targetClassOrMethod [

	^ self method
]

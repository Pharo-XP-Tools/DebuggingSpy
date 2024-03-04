"
I represent an abstract window event record, typically an opening, closing, resizing, or activation of a window.
I hold a unique window ID that corresponds to the original window object's identity hash. This ID should be used to group together all events related to that particular window.

I should be used from my class-side interface, called on my subclasses to match particular window events.
"
Class {
	#name : #DSWindowEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'windowName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSWindowEventRecord >> record: aWindowEvent [
	self recordWindowIdFromEvent: aWindowEvent.
	self recordWindowNameFromEvent: aWindowEvent
]

{ #category : #recording }
DSWindowEventRecord >> recordWindowIdFromEvent: anEvent [
	|win|
	win := anEvent window.
	windowId := win identityHash
]

{ #category : #recording }
DSWindowEventRecord >> recordWindowNameFromEvent: anEvent [

	windowName := [ anEvent window label ]
		              on: Error
		              do: [ 'Unknown window' ]
]

{ #category : #comparing }
DSWindowEventRecord >> sameWindowAsIn: aDSWindowEventRecord [
	^self windowId = aDSWindowEventRecord windowId
]

{ #category : #accessing }
DSWindowEventRecord >> windowName [

	^ windowName
]

{ #category : #accessing }
DSWindowEventRecord >> windowName: anObject [

	windowName := anObject
]

{ #category : #'as yet unclassified' }
DSWindowEventRecord >> windowType [

	| rs type |
	((windowName splitOn: Character space) includes: 'senders') ifTrue:[^'Senders'].
	((windowName splitOn: Character space) includes: 'implementors') ifTrue:[^'Implementors'].
	
	rs := windowName readStream.
	type := rs upTo: Character space.		
	type size = 1 ifTrue: [ type := rs upTo: $( ].
	^ type
]

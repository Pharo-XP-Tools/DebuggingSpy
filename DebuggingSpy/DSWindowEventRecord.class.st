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
	((windowName splitOn: Character space) includes: 'Senders') ifTrue:[^'Senders'].
	((windowName splitOn: Character space) includes: 'implementors') ifTrue:[^'Implementors'].
	((windowName splitOn: Character space) includes: 'Implementors') ifTrue:[^'Implementors'].

	rs := windowName readStream.
	type := rs upTo: Character space.
	type size = 1 ifTrue: [ type := rs upTo: $( ].
	(#('Spotter' 'implementors' 'Inspector'  'Debugger' 'Implementors' 'Breakpoint' 'Transcript' 'Browser' 'ClyQueryBrowserMorph' 'ClyFullBrowserMorph' 'CORMAS - ECECModel') includes: type) ifTrue:[^type].
	type isNumber ifTrue:[^'X'].
	^ 'Application'
]

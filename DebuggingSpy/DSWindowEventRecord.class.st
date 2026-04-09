"
Class which represent a record of a window event : openned, closed or activated.

This type of record is useful to know which are the tools used by a developper.
"
Class {
	#name : 'DSWindowEventRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'windowName',
		'toolInfo'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSWindowEventRecord >> record: aWindowEvent [

	| tool |
	self windowId: aWindowEvent window identityHash.
	self recordWindowNameFromEvent: aWindowEvent.
	tool := DSSpy toolInWindow: aWindowEvent window.
	tool ifNil: [ ^ self ].
	toolInfo := DSToolInfo toolClass: tool class id: tool identityHash windowId: windowId
]

{ #category : 'recording' }
DSWindowEventRecord >> recordWindowNameFromEvent: anEvent [

	windowName := [ anEvent window label ]
		              on: Error
		              do: [ 'Unknown window' ]
]

{ #category : 'comparing' }
DSWindowEventRecord >> sameWindowAsIn: aDSWindowEventRecord [
	^self windowId = aDSWindowEventRecord windowId
]

{ #category : 'accessing' }
DSWindowEventRecord >> toolInfo [

	^ toolInfo
]

{ #category : 'accessing' }
DSWindowEventRecord >> toolInfo: aToolInfo [

	toolInfo := aToolInfo
]

{ #category : 'accessing' }
DSWindowEventRecord >> windowName [

	^ windowName ifNil: [ ^ windowId ]
]

{ #category : 'accessing' }
DSWindowEventRecord >> windowName: anObject [

	windowName := anObject
]

{ #category : 'actions api' }
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

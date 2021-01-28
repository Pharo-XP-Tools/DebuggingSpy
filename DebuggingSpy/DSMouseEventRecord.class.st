"
I record different kinds of mouse events in order to track what the users moves the mouse and on what items he is clicking.
For example the following events:
- mouse enter windows W that is a class browser
- mouse click on the item corresponding to the method #foo
means the user is currently browsing the method foo (and we assume there she reads the code)..
"
Class {
	#name : #DSMouseEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'itemElement',
		'windowId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseEventRecord >> itemElement [

	^ itemElement
]

{ #category : #accessing }
DSMouseEventRecord >> itemElement: anObject [

	itemElement := anObject
]

{ #category : #'actions api' }
DSMouseEventRecord >> record: morphsAndWindow [

	itemElement := self class printStringMorphs: morphsAndWindow first.
	windowId := morphsAndWindow last hash
]

{ #category : #accessing }
DSMouseEventRecord >> windowId [

	^ windowId
]

{ #category : #accessing }
DSMouseEventRecord >> windowId: anObject [

	windowId := anObject
]

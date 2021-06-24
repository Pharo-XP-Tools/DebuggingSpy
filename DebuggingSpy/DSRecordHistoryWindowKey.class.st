"
I am a simple key to sort logs by windows.
"
Class {
	#name : #DSRecordHistoryWindowKey,
	#superclass : #Object,
	#instVars : [
		'windowName',
		'windowId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #printing }
DSRecordHistoryWindowKey >> printOn: aStream [

	aStream << (windowName ifNil: [ 'Unnamed window' ]).
	aStream space.
	aStream << '['.
	aStream << windowId printString.
	aStream << ']'
]

{ #category : #accessing }
DSRecordHistoryWindowKey >> windowId [

	^ windowId
]

{ #category : #accessing }
DSRecordHistoryWindowKey >> windowId: anObject [

	windowId := anObject
]

{ #category : #accessing }
DSRecordHistoryWindowKey >> windowName [

	^ windowName
]

{ #category : #accessing }
DSRecordHistoryWindowKey >> windowName: anObject [

	windowName := anObject
]

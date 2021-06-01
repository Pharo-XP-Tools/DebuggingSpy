"
I simulate a task that can be managed through DSSpy.
"
Class {
	#name : #DSTask,
	#superclass : #Object,
	#instVars : [
		'answer'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #accessing }
DSTask class >> dsTaskDescription [

	^ 'DS test task'
]

{ #category : #accessing }
DSTask >> answer [ 	
	^answer
]

{ #category : #accessing }
DSTask >> answer: anObject [

	answer := anObject
]

{ #category : #accessing }
DSTask >> description [ 	
	^self class dsTaskDescription
]

{ #category : #initialization }
DSTask >> initialize [

	super initialize.
	answer := self class dsTaskDescription
]

{ #category : #accessing }
DSTask >> name [ 	
	^self class dsTaskDescription
]

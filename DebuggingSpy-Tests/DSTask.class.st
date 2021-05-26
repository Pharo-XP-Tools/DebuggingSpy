"
I simulate a task that can be managed through DSSpy.
"
Class {
	#name : #DSTask,
	#superclass : #Object,
	#category : #'DebuggingSpy-Tests'
}

{ #category : #accessing }
DSTask class >> dsTaskDescription [

	^ 'DS test task'
]

{ #category : #accessing }
DSTask >> answer [ 	
	^self class dsTaskDescription
]

{ #category : #accessing }
DSTask >> description [ 	
	^self class dsTaskDescription
]

{ #category : #accessing }
DSTask >> name [ 	
	^self class dsTaskDescription
]

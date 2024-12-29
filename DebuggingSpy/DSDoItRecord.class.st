"
I record when the user selects code and debugs it.
"
Class {
	#name : #DSDoItRecord,
	#superclass : #DSCodeActionRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSDoItRecord >> eventName [ 
	^'Do it'
]

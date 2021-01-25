"
I record when the user selects code and debugs it.
"
Class {
	#name : #DSDebugItRecord,
	#superclass : #DSCodeActionRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSDebugItRecord >> eventName [ 
	^'Debug it'
]

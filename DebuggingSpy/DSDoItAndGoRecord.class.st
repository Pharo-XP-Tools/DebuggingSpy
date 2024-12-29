"
I record when the user selects code, executes it and inspect the result immediately.
"
Class {
	#name : #DSDoItAndGoRecord,
	#superclass : #DSDoItRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSDoItAndGoRecord >> eventName [ 
	^'Do it and Go'
]

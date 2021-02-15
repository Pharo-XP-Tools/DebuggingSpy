"
I record that a StPlayground opened.
"
Class {
	#name : #DSPlaygroundOpenedRecord,
	#superclass : #DSPlaygroundRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSPlaygroundOpenedRecord >> eventName [
	^'Playground open' 
]

"
I record when a window is closed.
"
Class {
	#name : #DSWindowClosedRecord,
	#superclass : #DSWindowEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSWindowClosedRecord >> eventName [
	^'Window closed'
]

"
I record when a window is opened.
"
Class {
	#name : #DSWindowOpenedRecord,
	#superclass : #DSWindowEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSWindowOpenedRecord >> eventName [
	^'Window opened'
]

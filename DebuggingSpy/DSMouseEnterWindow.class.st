"
This record is generated when the mouse enters a window (with or without focus).
"
Class {
	#name : #DSMouseEnterWindow,
	#superclass : #DSMouseEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseEnterWindow >> eventName [
	^'Enter window'
]

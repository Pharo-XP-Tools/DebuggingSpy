"
This record is generated when the mouse leaves a window (with or without focus).
"
Class {
	#name : #DSMouseLeaveWindow,
	#superclass : #DSMouseEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseLeaveWindow >> eventName [
	^'Leave window'
]

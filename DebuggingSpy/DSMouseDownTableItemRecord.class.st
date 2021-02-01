"
This record is generated when the mouse clicks an item in a table.
"
Class {
	#name : #DSMouseDownTableItemRecord,
	#superclass : #DSMouseEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseDownTableItemRecord >> eventName [
	^'Click on table item'
]

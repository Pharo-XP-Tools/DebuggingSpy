"
This record is generated when the mouse enters an item in a text editor.
"
Class {
	#name : #DSMouseEnterTextEditorRecord,
	#superclass : #DSMouseEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMouseEnterTextEditorRecord >> eventName [
	^'Mouse on text editor'
]

"
I record clipboard actions such as copy and paste.
The records might include the clipboard text if the the shared variable #registerClipboardText is true (default value is false).
The record also includes the windowId and the editor class name.
"
Class {
	#name : #DSClipboardActionRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'clipboardText',
		'editorClassName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSClipboardActionRecord >> clipboardText [

	^ clipboardText
]

{ #category : #accessing }
DSClipboardActionRecord >> clipboardText: anObject [

	clipboardText := anObject
]

{ #category : #accessing }
DSClipboardActionRecord >> editorClassName [

	^ editorClassName
]

{ #category : #accessing }
DSClipboardActionRecord >> editorClassName: anObject [

	editorClassName := anObject
]

{ #category : #'actions api' }
DSClipboardActionRecord >> record: recordInfo [
	clipboardText  := DSSpy recordClipboardContent ifTrue: [ recordInfo first] ifFalse: ['RecordClipboarContent disabled'].
	windowId := recordInfo second.
	editorClassName := recordInfo third
]

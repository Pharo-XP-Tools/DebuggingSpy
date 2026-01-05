"
I record clipboard actions such as copy and paste.
The records might include the clipboard text if the the shared variable #registerClipboardText is true (default value is false).
The record also includes the windowId and the editor class name.
"
Class {
	#name : 'DSClipboardActionRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'clipboardText',
		'editorClassName'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSClipboardActionRecord >> clipboardText [

	^ clipboardText
]

{ #category : 'accessing' }
DSClipboardActionRecord >> clipboardText: anObject [

	clipboardText := anObject
]

{ #category : 'accessing' }
DSClipboardActionRecord >> editorClassName [

	^ editorClassName
]

{ #category : 'accessing' }
DSClipboardActionRecord >> editorClassName: anObject [

	editorClassName := anObject
]

{ #category : 'actions api' }
DSClipboardActionRecord >> record: anEditor [

	clipboardText := DSSpy recordClipboardContent
		                 ifTrue: [ anEditor selection asString ]
		                 ifFalse: [ 'RecordClipboarContent disabled' ].
	windowId := anEditor textArea window hash.
	editorClassName := anEditor class name
]

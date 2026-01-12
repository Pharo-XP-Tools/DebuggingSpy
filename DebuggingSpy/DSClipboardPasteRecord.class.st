"
I record when a user is doing a paste from clipboard action.
"
Class {
	#name : 'DSClipboardPasteRecord',
	#superclass : 'DSClipboardActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSClipboardPasteRecord >> eventName [

	^ 'Clipboard Paste'
]

{ #category : 'actions api' }
DSClipboardPasteRecord >> record: anEditor [

	clipboardText := DSSpy recordClipboardContent
		                 ifTrue: [ Clipboard clipboardText ]
		                 ifFalse: [ 'RecordClipboarContent disabled' ].

	super record: anEditor
]

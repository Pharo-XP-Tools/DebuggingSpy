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

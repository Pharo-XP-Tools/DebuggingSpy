Class {
	#name : #DSClipboardPasteRecord,
	#superclass : #DSClipboardActionRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSClipboardPasteRecord >> eventName [

	^ 'Clipboard Paste'
]

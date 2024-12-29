Class {
	#name : #DSClipboardCopyRecord,
	#superclass : #DSClipboardActionRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSClipboardCopyRecord >> eventName [

	^ 'Clipboard Copy'
]

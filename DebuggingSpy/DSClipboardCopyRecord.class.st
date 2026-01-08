"
I record when a user is doing a copy to clipboard action.
"
Class {
	#name : 'DSClipboardCopyRecord',
	#superclass : 'DSClipboardActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSClipboardCopyRecord >> eventName [

	^ 'Clipboard Copy'
]

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

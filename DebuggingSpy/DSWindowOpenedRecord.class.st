"
I record when a window is opened.
"
Class {
	#name : 'DSWindowOpenedRecord',
	#superclass : 'DSWindowEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'example' }
DSWindowOpenedRecord class >> example [
	| event record toolInfo |
	event := WindowOpened  new window: MorphicNativeWindow basicNew.
	record := self new.
	record recordWindowIdFromEvent: event.
	record recordWindowNameFromEvent: event.
	toolInfo := DSToolInfo
		            toolNamed: 'DSWindowOpened example'
		            id: 0
		            windowId: record windowId.
	record toolInfo: toolInfo.
	^record
]

{ #category : 'accessing' }
DSWindowOpenedRecord >> eventName [
	^'Window opened'
]

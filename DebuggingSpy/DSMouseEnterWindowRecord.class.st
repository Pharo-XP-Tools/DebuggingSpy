"
This record is generated when the mouse enters a window (with or without focus).
"
Class {
	#name : 'DSMouseEnterWindowRecord',
	#superclass : 'DSMouseEventRecord',
	#instVars : [
		'toolInfo'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMouseEnterWindowRecord >> eventName [
	^'Enter window'
]

{ #category : 'actions api' }
DSMouseEnterWindowRecord >> record: morphsAndWindow [

	| window tool |
	super record: morphsAndWindow.
	window := morphsAndWindow last.
	window ifNil: [ ^ self ].
	tool := DSSpy toolInWindow: window.
	tool ifNil: [ ^ self ].
	toolInfo := DSToolInfo
		            toolNamed: tool class name
		            id: tool identityHash
		            windowId: windowId
]

{ #category : 'accessing' }
DSMouseEnterWindowRecord >> toolInfo [
	^ toolInfo
]

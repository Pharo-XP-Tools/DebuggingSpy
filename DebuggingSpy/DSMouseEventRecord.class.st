"
I record different kinds of mouse events in order to track what the users moves the mouse and on what items he is clicking.
For example the following events:
- mouse enter windows W that is a class browser
- mouse click on the item corresponding to the method #foo
means the user is currently browsing the method foo (and we assume there she reads the code)..
"
Class {
	#name : 'DSMouseEventRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'toolInfo'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSMouseEventRecord >> record: aWindow [

	| tool |
	self windowId: aWindow identityHash.

	tool := DSSpy toolInWindow: aWindow.
	tool ifNil: [ ^ self ].
	toolInfo := DSToolInfo toolClass: tool class id: tool identityHash windowId: windowId
]

{ #category : 'accessing' }
DSMouseEventRecord >> toolInfo [ 

	^ toolInfo 
]

{ #category : 'accessing' }
DSMouseEventRecord >> toolInfo: aDSToolInfo [ 

	toolInfo := aDSToolInfo
]

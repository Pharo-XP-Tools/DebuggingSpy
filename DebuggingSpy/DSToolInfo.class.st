"
I represent information about a tool used in the IDE.
I know the window identity hash in which I have been opened.
"
Class {
	#name : 'DSToolInfo',
	#superclass : 'Object',
	#instVars : [
		'toolClassName',
		'toolIdentityHash',
		'windowIdentityHash'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'instance creation' }
DSToolInfo class >> toolNamed: aToolName id: aToolId windowId: aWindowId [

	^ self new
		  toolClassName: aToolName;
		  toolIdentityHash: aToolId;
		  windowIdentityHash: aWindowId;
		  yourself
]

{ #category : 'printing' }
DSToolInfo >> printOn: str [

	str << (toolClassName ifNil: [ 'missing tool name' ]).
	str space.
]

{ #category : 'accessing' }
DSToolInfo >> toolClassName [

	^ toolClassName
]

{ #category : 'accessing' }
DSToolInfo >> toolClassName: anObject [

	toolClassName := anObject
]

{ #category : 'accessing' }
DSToolInfo >> toolIdentityHash [

	^ toolIdentityHash
]

{ #category : 'accessing' }
DSToolInfo >> toolIdentityHash: anObject [

	toolIdentityHash := anObject
]

{ #category : 'accessing' }
DSToolInfo >> windowIdentityHash [

	^ windowIdentityHash
]

{ #category : 'accessing' }
DSToolInfo >> windowIdentityHash: anObject [

	windowIdentityHash := anObject
]

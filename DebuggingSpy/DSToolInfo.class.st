"
I represent information about a tool used in the IDE.
I know the window identity hash in which I have been opened.
"
Class {
	#name : 'DSToolInfo',
	#superclass : 'Object',
	#instVars : [
		'toolClass',
		'toolIdentityHash',
		'windowIdentityHash'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSToolInfo class >> toolClass: aToolName id: aToolId windowId: aWindowId [

	^ self new
		  toolClass: aToolName;
		  toolIdentityHash: aToolId;
		  windowIdentityHash: aWindowId;
		  yourself
]

{ #category : 'printing' }
DSToolInfo >> printOn: str [

	str << (toolClass ifNil: [ 'missing tool name' ]).
	str space.
]

{ #category : 'accessing' }
DSToolInfo >> toolClass [

	^ toolClass
]

{ #category : 'accessing' }
DSToolInfo >> toolClass: anObject [

	toolClass := anObject
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

{ #category : 'accessing' }
DSToolInfo >> windowType [
	"Returns the window type if the tool is known, and external window otherwise."

	toolClass ifNotNil: [ ^ toolClass windowType ].
	^ 'External Window'
]

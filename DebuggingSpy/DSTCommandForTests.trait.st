"
I provide an accessor to tell that a debugging command is used within a test, in order to avoid executing too much debugging code (and for example to make the execution loop indefinitely when we proceed an infinite recursion).
"
Trait {
	#name : 'DSTCommandForTests',
	#instVars : [
		'forTests'
	],
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'accessing' }
DSTCommandForTests >> forTests [

	^ forTests ifNil: [ forTests := false ]
]

{ #category : 'accessing' }
DSTCommandForTests >> forTests: anObject [

	forTests := anObject
]

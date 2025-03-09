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

	^ forTests ifNil: [ forTests := false ] ifNotNil: [ forTests ]
]

{ #category : 'accessing' }
DSTCommandForTests >> forTests: anObject [

	forTests := anObject
]

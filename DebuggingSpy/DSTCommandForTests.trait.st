Trait {
	#name : #DSTCommandForTests,
	#instVars : [
		'forTests'
	],
	#category : #'DebuggingSpy-Commands'
}

{ #category : #accessing }
DSTCommandForTests >> forTests [

	^ forTests ifNil: [ forTests := false ] ifNotNil: [ forTests ]
]

{ #category : #accessing }
DSTCommandForTests >> forTests: anObject [

	forTests := anObject
]

"
I specialize SindarinStepToNextInstanceCreation with debugging spy record creation.
	I am meant to replace SindarinStepToNextInstanceCreation commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSSindarinStepToNextInstanceCreation',
	#superclass : 'SindarinStepToNextInstanceCreation',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'executing' }
DSSindarinStepToNextInstanceCreation >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_NEXT_INSTANCE_CREATION].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

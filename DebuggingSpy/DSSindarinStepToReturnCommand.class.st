"
I specialize SindarinStepToReturnCommand with debugging spy record creation.
	I am meant to replace SindarinStepToReturnCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSSindarinStepToReturnCommand',
	#superclass : 'SindarinStepToReturnCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'executing' }
DSSindarinStepToReturnCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_RETURN].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

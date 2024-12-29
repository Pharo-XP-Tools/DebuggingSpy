"
I specialize SindarinStepToReturnCommand with debugging spy record creation.
	I am meant to replace SindarinStepToReturnCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSndarinStepToReturnCommand',
	#superclass : 'SindarinStepToReturnCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'executing' }
DSndarinStepToReturnCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_RETURN].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

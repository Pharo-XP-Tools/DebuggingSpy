"
I specialize SindarinStepToNextCallInClassCommand with debugging spy record creation.
	I am meant to replace SindarinStepToNextCallInClassCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSSindarinStepToNextCallInClassCommand',
	#superclass : 'SindarinStepToNextCallInClassCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'hooks' }
DSSindarinStepToNextCallInClassCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_NEXT_CALL_IN_CLASS].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

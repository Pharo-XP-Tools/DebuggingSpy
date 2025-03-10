"
I specialize SindarinStepToNextCallInObjectCommand with debugging spy record creation.
	I am meant to replace SindarinStepToNextCallInObjectCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSndarinStepToNextCallInObjectCommand',
	#superclass : 'SindarinStepToNextCallInObjectCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'hooks' }
DSndarinStepToNextCallInObjectCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_NEXT_CALL_IN_OBJECT].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

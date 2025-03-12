"
I specialize SindarinStepToMethodEntryCommand with debugging spy record creation.
	I am meant to replace SindarinStepToMethodEntryCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSSindarinStepToMethodEntryCommand',
	#superclass : 'SindarinStepToMethodEntryCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'executing' }
DSSindarinStepToMethodEntryCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #TO_METHOD_ENTRY].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

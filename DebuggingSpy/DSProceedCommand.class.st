"
I specialize StProceedCommand with debugging spy record creation.
	I am meant to replace StProceedCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSProceedCommand',
	#superclass : 'StProceedCommand',
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'hooks' }
DSProceedCommand >> execute [

	[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #PROCEED].
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

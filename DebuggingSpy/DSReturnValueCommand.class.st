"
I specialize StReturnValueCommand with debugging spy record creation.
	I am meant to replace StReturnValueCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSReturnValueCommand,
	#superclass : #StReturnValueCommand,
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSReturnValueCommand >> execute [
		DSStepActionRecord for: self.
		self forTests ifTrue: [ ^ self ].
		^super execute.
]

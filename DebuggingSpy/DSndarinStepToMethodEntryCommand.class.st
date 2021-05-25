"
I specialize SindarinStepToMethodEntryCommand with debugging spy record creation.
	I am meant to replace SindarinStepToMethodEntryCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToMethodEntryCommand,
	#superclass : #SindarinStepToMethodEntryCommand,
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToMethodEntryCommand >> execute [

	DSStepActionRecord for: self.
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

"
I specialize SindarinStepToNextCallInObjectCommand with debugging spy record creation.
	I am meant to replace SindarinStepToNextCallInObjectCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToNextCallInObjectCommand,
	#superclass : #SindarinStepToNextCallInObjectCommand,
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToNextCallInObjectCommand >> execute [

	DSStepActionRecord for: self.
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

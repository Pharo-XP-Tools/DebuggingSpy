"
I specialize StProceedCommand with debugging spy record creation.
	I am meant to replace StProceedCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSProceedCommand,
	#superclass : #StProceedCommand,
	#traits : 'DSTCommandForTests',
	#classTraits : 'DSTCommandForTests classTrait',
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSProceedCommand >> execute [

	DSStepActionRecord for: self.
	self forTests ifTrue: [ ^ self ].
	^ super execute
]

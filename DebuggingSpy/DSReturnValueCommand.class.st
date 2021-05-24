"
I specialize StReturnValueCommand with debugging spy record creation.
	I am meant to replace StReturnValueCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSReturnValueCommand,
	#superclass : #StReturnValueCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSReturnValueCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

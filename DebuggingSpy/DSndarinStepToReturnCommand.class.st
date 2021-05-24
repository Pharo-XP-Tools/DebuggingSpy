"
I specialize SindarinStepToReturnCommand with debugging spy record creation.
	I am meant to replace SindarinStepToReturnCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToReturnCommand,
	#superclass : #SindarinStepToReturnCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToReturnCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

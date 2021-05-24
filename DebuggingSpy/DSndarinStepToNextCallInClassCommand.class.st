"
I specialize SindarinStepToNextCallInClassCommand with debugging spy record creation.
	I am meant to replace SindarinStepToNextCallInClassCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToNextCallInClassCommand,
	#superclass : #SindarinStepToNextCallInClassCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToNextCallInClassCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

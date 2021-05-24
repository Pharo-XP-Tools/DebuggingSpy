"
I specialize SindarinStepToNextCallInObjectCommand with debugging spy record creation.
	I am meant to replace SindarinStepToNextCallInObjectCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToNextCallInObjectCommand,
	#superclass : #SindarinStepToNextCallInObjectCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToNextCallInObjectCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

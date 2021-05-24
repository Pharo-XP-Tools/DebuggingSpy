"
I specialize SindarinStepToNextInstanceCreation with debugging spy record creation.
	I am meant to replace SindarinStepToNextInstanceCreation commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToNextInstanceCreation,
	#superclass : #SindarinStepToNextInstanceCreation,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToNextInstanceCreation >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

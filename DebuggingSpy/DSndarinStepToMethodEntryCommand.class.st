"
I specialize SindarinStepToMethodEntryCommand with debugging spy record creation.
	I am meant to replace SindarinStepToMethodEntryCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSndarinStepToMethodEntryCommand,
	#superclass : #SindarinStepToMethodEntryCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSndarinStepToMethodEntryCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

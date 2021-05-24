"
I specialize StStepIntoCommand with debugging spy record creation.
	I am meant to replace StStepIntoCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSStepIntoCommand,
	#superclass : #StStepIntoCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSStepIntoCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

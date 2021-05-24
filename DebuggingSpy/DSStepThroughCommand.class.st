"
I specialize StStepThroughCommand with debugging spy record creation.
	I am meant to replace StStepThroughCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSStepThroughCommand,
	#superclass : #StStepThroughCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSStepThroughCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

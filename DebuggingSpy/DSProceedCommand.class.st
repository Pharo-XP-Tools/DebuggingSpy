"
I specialize StProceedCommand with debugging spy record creation.
	I am meant to replace StProceedCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSProceedCommand,
	#superclass : #StProceedCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSProceedCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

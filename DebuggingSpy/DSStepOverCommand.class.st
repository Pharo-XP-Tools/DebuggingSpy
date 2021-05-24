"
I specialize StStepOverCommand with debugging spy record creation.
	I am meant to replace StStepOverCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSStepOverCommand,
	#superclass : #StStepOverCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSStepOverCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

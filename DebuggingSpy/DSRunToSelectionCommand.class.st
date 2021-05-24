"
I specialize StRunToSelectionCommand with debugging spy record creation.
	I am meant to replace StRunToSelectionCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSRunToSelectionCommand,
	#superclass : #StRunToSelectionCommand,
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSRunToSelectionCommand >> execute [
		DSStepActionRecord for: self.
		^super execute.
]

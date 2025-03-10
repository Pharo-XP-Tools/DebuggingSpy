"
I specialize StRunToSelectionCommand with debugging spy record creation.
	I am meant to replace StRunToSelectionCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSRunToSelectionCommand',
	#superclass : 'StRunToSelectionCommand',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'hooks' }
DSRunToSelectionCommand >> execute [
		[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #RUN_TO].
		^super execute.
]

"
I specialize StRestartCommand with debugging spy record creation.
	I am meant to replace StRestartCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : 'DSRestartCommand',
	#superclass : 'StRestartCommand',
	#category : 'DebuggingSpy-Commands',
	#package : 'DebuggingSpy',
	#tag : 'Commands'
}

{ #category : 'hooks' }
DSRestartCommand >> execute [
		[DSStepActionRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #RESTART].
		^super execute.
]

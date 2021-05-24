"
I specialize StReturnValueCommand with debugging spy record creation.
	I am meant to replace StReturnValueCommand commands in the debugger in order to provide such instrumentation.
"
Class {
	#name : #DSReturnValueCommand,
	#superclass : #StReturnValueCommand,
	#instVars : [
		'forTests'
	],
	#category : #'DebuggingSpy-Commands'
}

{ #category : #executing }
DSReturnValueCommand >> execute [
		DSStepActionRecord for: self.
		self forTests ifTrue: [ ^ self ].
		^super execute.
]

{ #category : #accessing }
DSReturnValueCommand >> forTests [

	^ forTests ifNil:[forTests := false]
]

{ #category : #accessing }
DSReturnValueCommand >> forTests: anObject [

	forTests := anObject
]

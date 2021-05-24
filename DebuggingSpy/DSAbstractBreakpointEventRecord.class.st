"
I record breakpoint events information, whatever the type of breakpoint.
My subclasses have to handle the real recording, depending on the breakpoint.
"
Class {
	#name : #DSAbstractBreakpointEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'target',
		'objectCentric',
		'eventName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSAbstractBreakpointEventRecord >> eventName [
	^eventName
]

{ #category : #'actions api' }
DSAbstractBreakpointEventRecord >> record: aBreakpointEvent [
	eventName := aBreakpointEvent class name.
	objectCentric := aBreakpointEvent breakpoint isObjectCentric.
	target := objectCentric
		          ifTrue: [ aBreakpointEvent breakpoint targetInstance printString ]
		          ifFalse: [ nil ]
]

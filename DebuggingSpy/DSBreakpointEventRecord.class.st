"
I record breakpoint events information.
"
Class {
	#name : #DSBreakpointEventRecord,
	#superclass : #DSAbstractBreakpointEventRecord,
	#instVars : [
		'method',
		'node'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSBreakpointEventRecord >> record: aBreakpointEvent [
	super record: aBreakpointEvent.
	method := aBreakpointEvent breakpoint node methodNode method name.
	node := aBreakpointEvent breakpoint node printString
]

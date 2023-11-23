"
I record breakpoint events information.
"
Class {
	#name : 'DSBreakpointEventRecord',
	#superclass : 'DSAbstractBreakpointEventRecord',
	#instVars : [
		'method',
		'node'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSBreakpointEventRecord >> method [

	^ method
]

{ #category : 'accessing' }
DSBreakpointEventRecord >> node [

	^ node
]

{ #category : 'actions api' }
DSBreakpointEventRecord >> record: aBreakpointEvent [
	super record: aBreakpointEvent.
	method := aBreakpointEvent breakpoint node methodNode method name.
	node := aBreakpointEvent breakpoint node printString
]

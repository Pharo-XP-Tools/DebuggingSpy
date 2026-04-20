Class {
	#name : 'DSMouseLeaveWindowRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSMouseLeaveWindowRecordTest >> testEventName [

	| record |
	record := DSMouseLeaveWindowRecord new.
	self assert: record eventName equals: 'Leave Unknown Window'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Leave Debugger'
]

Class {
	#name : 'DSWindowClosedRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSWindowClosedRecordTest >> testEventName [

	| record |
	record := DSWindowClosedRecord new.
	self assert: record eventName equals: 'Unknown Window closed'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Debugger closed'
]

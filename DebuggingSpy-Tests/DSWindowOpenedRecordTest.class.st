Class {
	#name : 'DSWindowOpenedRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSWindowOpenedRecordTest >> testEventName [

	| record |
	record := DSWindowOpenedRecord new.
	self assert: record eventName equals: 'Unknown Window opened'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Debugger opened'
]

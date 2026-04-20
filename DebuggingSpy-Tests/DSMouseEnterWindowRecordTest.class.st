Class {
	#name : 'DSMouseEnterWindowRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSMouseEnterWindowRecordTest >> testEventName [

	| record |
	record := DSMouseEnterWindowRecord new.
	self assert: record eventName equals: 'Enter Unknown Window'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Enter Debugger'
]

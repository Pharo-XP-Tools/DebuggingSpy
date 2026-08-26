Class {
	#name : 'DSWindowActivatedRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSWindowActivatedRecordTest >> testEventName [

	| record |
	record := DSWindowActivatedRecord new.
	self assert: record eventName equals: 'Unknown Window activated'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Debugger activated'
]

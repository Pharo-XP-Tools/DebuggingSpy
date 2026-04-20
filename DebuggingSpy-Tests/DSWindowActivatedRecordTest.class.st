Class {
	#name : 'DSWindowActivatedRecordTest',
	#superclass : 'DSWindowEventRecordTest',
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'tests' }
DSWindowActivatedRecordTest >> testEventName [

	| record |
	record := DSWindowActivatedRecord new.
	self assert: record eventName equals: 'Unknown Window activated'.

	record toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: record eventName equals: 'Debugger activated'
]

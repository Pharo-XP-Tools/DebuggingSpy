Class {
	#name : 'DSRecordHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'history'
	],
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'utilities' }
DSRecordHistoryTest >> getRecordsExample [

	| exampleRecords |
	
	exampleRecords := OrderedCollection new.
	
	exampleRecords add: (DSMouseEnterWindowRecord new windowId:1).
	exampleRecords add: (DSMouseLeaveWindowRecord new windowId:1).
	exampleRecords add: (DSMouseEnterWindowRecord new windowId:2).
	exampleRecords add: (DSDoItRecord new windowId:2).
	exampleRecords add: (DSMouseLeaveWindowRecord new windowId:2).
	
	^ exampleRecords
]

{ #category : 'running' }
DSRecordHistoryTest >> setUp [
	super setUp.
	history := DSRecordHistory new
]

{ #category : 'tests' }
DSRecordHistoryTest >> testAddWindowRecord [

	| record savedRecord |
	record := DSMouseEnterWindowRecord new windowId: 1.
	history addWindowRecord: record.
	self assert: history windowsHistory size equals: 1.
	savedRecord := (history windowsHistory at: (history findWindowRecordKeyForID: record windowId)) first.
	self assert: savedRecord equals: record.

	record := DSWindowActivatedRecord new windowId: 2.
	history addWindowRecord: record.
	self assert: history windowsHistory size equals: 2.
	savedRecord := (history windowsHistory at: (history findWindowRecordKeyForID: record windowId)) first.
	self assert: savedRecord equals: record.

	record := DSMouseLeaveWindowRecord new windowId: 1.
	history addWindowRecord: record.
	self assert: history windowsHistory size equals: 2.
	savedRecord := (history windowsHistory at: (history findWindowRecordKeyForID: record windowId)) second.
	self assert: savedRecord equals: record
]

{ #category : 'tests' }
DSRecordHistoryTest >> testFindWindowRecordKeyForID [

	| windowKey |
	windowKey := history findWindowRecordKeyForID: 1.
	self assert: windowKey class equals: DSRecordHistoryWindowKey.
	self assert: windowKey windowId equals: 1.
	self assert: history windowsHistory size equals: 0.

	windowKey := history findWindowRecordKeyForID: 2.
	self assert: windowKey class equals: DSRecordHistoryWindowKey.
	self assert: windowKey windowId equals: 2.
	self assert: history windowsHistory size equals: 0
]

{ #category : 'tests' }
DSRecordHistoryTest >> testWindowsHistory [

	| dictExample |
	self assert: history windowsHistory isNotNil.
	self assert: history windowsHistory class equals: IdentityDictionary.

	dictExample := IdentityDictionary new
		               at: 'cat' put: 1;
		               at: 'dog' put: 2.
	history windowsHistory: dictExample.
	self assert: history windowsHistory equals: dictExample
]

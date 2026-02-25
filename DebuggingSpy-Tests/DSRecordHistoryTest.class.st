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
	
	exampleRecords add: (DSMouseEnterWindowRecord new windowId:1; dateTime: '2000-05-07T15:02:44' asDateAndTime).
	exampleRecords add: (DSMouseLeaveWindowRecord new windowId:1).
	exampleRecords add: (DSMouseEnterWindowRecord new windowId:2).
	exampleRecords add: (DSDoItRecord new windowId:2).
	exampleRecords add: (DSMouseLeaveWindowRecord new windowId:2; dateTime: '2000-05-07T15:03:14' asDateAndTime).
	
	^ exampleRecords
]

{ #category : 'running' }
DSRecordHistoryTest >> setUp [
	super setUp.
	history := DSRecordHistory new
]

{ #category : 'tests' }
DSRecordHistoryTest >> testAbsoluteTimeTaken [

	history records: self getRecordsExample.
	self assert: history absoluteTimeTaken equals: 0.5
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
DSRecordHistoryTest >> testAllRecordsOfKind [

	| record |
	history records: self getRecordsExample.

	self assert: (history allRecordsOfKind: DSMouseLeaveWindowRecord) size equals: 2.
	record := (history allRecordsOfKind: DSMouseLeaveWindowRecord) first.
	self assert: record class equals: DSMouseLeaveWindowRecord.
	self assert: record windowId equals: 1.

	self assert: (history allRecordsOfKind: DSDoItRecord) size equals: 1.
	record := (history allRecordsOfKind: DSDoItRecord) first.
	self assert: record class equals: DSDoItRecord.
	self assert: record windowId equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDateTime [

	history records: self getRecordsExample.
	self assert: history dateTime equals: '2000-05-07T15:02:44' asDateAndTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointAdds [

	history records: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name) } asOrderedCollection.
	self assert: history debugPointAdds equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointHit [

	history records: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name) } asOrderedCollection.
	self assert: history debugPointHit equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointRemoved [

	history records: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointRemoved name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointRemoved name) } asOrderedCollection.
	self assert: history debugPointRemoved equals: 2
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
DSRecordHistoryTest >> testStartTime [

	history records: self getRecordsExample.
	self assert: history startTime equals: '15:02:44' asTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testStopTime [

	history records: self getRecordsExample.
	self assert: history stopTime equals: '15:03:14' asTime
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

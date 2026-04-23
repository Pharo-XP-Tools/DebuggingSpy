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

	exampleRecords add: (DSMouseEnterWindowRecord new
			 windowId: 1;
			 dateTime: '2000-05-07T15:02:44' asDateAndTime).
	exampleRecords add: (DSMouseLeaveWindowRecord new
			 windowId: 1;
			 dateTime: '2000-05-07T15:03:56' asDateAndTime).
	exampleRecords add: (DSMouseEnterWindowRecord new
			 windowId: 2;
			 dateTime: '2000-05-07T15:06:05' asDateAndTime).
	exampleRecords add: (DSDoItRecord new
			 windowId: 2;
			 dateTime: '2000-05-07T15:13:47' asDateAndTime).
	exampleRecords add: (DSMouseLeaveWindowRecord new
			 windowId: 2;
			 dateTime: '2000-05-07T15:24:44' asDateAndTime).

	^ exampleRecords
]

{ #category : 'running' }
DSRecordHistoryTest >> setUp [
	super setUp.
	history := DSRecordHistory new
]

{ #category : 'tests' }
DSRecordHistoryTest >> testAbsoluteTimeTaken [

	history events: self getRecordsExample.
	self assert: history absoluteTimeTaken equals: 22 * 60
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
	history events: self getRecordsExample.

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
DSRecordHistoryTest >> testBuildWindowHistory [

	| windowsHistory listOfRecords |
	history events: {
			DSDoItRecord new.
			(DSWindowOpenedRecord new
				 windowId: 1;
				 windowName: 'playgroundWindow').
			(DSMouseEnterWindowRecord new windowId: 1).
			DSMethodAddedRecord new.
			(DSMethodRemovedRecord new windowId: 1).
			(DSMouseLeaveWindowRecord new windowId: 1).
			DSReturnValue new.
			(DSWindowOpenedRecord new
				 windowId: 3;
				 windowName: 'browserWindow').
			DSStepIntoRecord new.
			(DSMouseLeaveWindowRecord new windowId: 3).
			DSPrintItRecord new.
			(DSStepThroughRecord new windowId: 3) } asOrderedCollection.

	history buildWindowHistory.
	windowsHistory := history windowsHistory.

	self assert: windowsHistory class equals: IdentityDictionary.
	self assert: windowsHistory size equals: 3.
	self assert: (windowsHistory keys detect: [ :k | k windowId = 1 ]) windowName equals: 'playgroundWindow'.
	self assert: (windowsHistory keys detect: [ :k | k windowId = 3 ]) windowName equals: 'browserWindow'.
	self assert: (windowsHistory keys detect: [ :k | k windowId = -1 ]) windowName isNil.

	listOfRecords := windowsHistory at: (windowsHistory keys detect: [ :k | k windowId = 1 ]).
	self assert: listOfRecords size equals: 5.
	self assert: listOfRecords first class equals: DSWindowOpenedRecord.
	self assert: listOfRecords last class equals: DSMouseLeaveWindowRecord.

	listOfRecords := windowsHistory at: (windowsHistory keys detect: [ :k | k windowId = 3 ]).
	self assert: listOfRecords size equals: 4.
	self assert: listOfRecords first class equals: DSWindowOpenedRecord.
	self assert: listOfRecords last class equals: DSStepThroughRecord.

	listOfRecords := windowsHistory at: (windowsHistory keys detect: [ :k | k windowId = -1 ]).
	self assert: listOfRecords size equals: 3.
	self assert: listOfRecords first class equals: DSDoItRecord.
	self assert: listOfRecords second class equals: DSReturnValue.
	self assert: listOfRecords third class equals: DSPrintItRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testBuildWindowJumps [

	history filteredWindows: {
			(DSWindowRecord new activePeriods: {
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T05:30:00' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T06:15:03' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSDoItRecord new.
								  DSMouseLeaveWindowRecord new }).
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T09:26:00' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T09:26:00' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSClipboardCopyRecord new.
								  DSStepIntoRecord new.
								  DSMouseLeaveWindowRecord new }).
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T14:47:00' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T14:48:24' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSStepIntoRecord new.
								  DSPrintItRecord new.
								  DSMouseLeaveWindowRecord new }).
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T19:30:00' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T19:34:57' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSMouseLeaveWindowRecord new }) } asOrderedCollection).
			(DSWindowRecord new activePeriods: { (DSWindowActivityRecord new
					  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T18:35:00' asDateAndTime);
					  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T18:47:00' asDateAndTime);
					  events: {
							  DSMouseEnterWindowRecord new.
							  DSDoItRecord new.
							  DSPrintItRecord new.
							  DSClipboardCopyRecord new.
							  DSMouseLeaveWindowRecord new }) } asOrderedCollection).
			(DSWindowRecord new activePeriods: {
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T11:32:00' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T11:56:34' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSDoItRecord new.
								  DSInspectItRecord new.
								  DSMouseLeaveWindowRecord new }).
					 (DSWindowActivityRecord new
						  start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T22:01:56' asDateAndTime);
						  stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T22:09:15' asDateAndTime);
						  events: {
								  DSMouseEnterWindowRecord new.
								  DSMouseLeaveWindowRecord new }) } asOrderedCollection) } asOrderedCollection.

	history buildWindowJumps.

	self assert: history windowJumps size equals: 7.
	self assert: history windowJumps first class equals: DSWindowActivityRecord.
	self assert: history windowJumps first start dateTime equals: '2025-09-01T05:30:00' asDateAndTime.
	self assert: history windowJumps first stop dateTime equals: '2025-09-01T06:15:03' asDateAndTime.
	self assert: history windowJumps third start dateTime equals: '2025-09-01T11:32:00' asDateAndTime.
	self assert: history windowJumps third stop dateTime equals: '2025-09-01T11:56:34' asDateAndTime.
	self assert: (history windowJumps at: 5) start dateTime equals: '2025-09-01T18:35:00' asDateAndTime.
	self assert: (history windowJumps at: 5) stop dateTime equals: '2025-09-01T18:47:00' asDateAndTime.
	self assert: history windowJumps last start dateTime equals: '2025-09-01T22:01:56' asDateAndTime.
	self assert: history windowJumps last stop dateTime equals: '2025-09-01T22:09:15' asDateAndTime.

	self assert: history filteredWindowJumps size equals: 3.
	self assert: history filteredWindowJumps first class equals: DSWindowActivityRecord.
	self assert: history filteredWindowJumps first start dateTime equals: '2025-09-01T11:32:00' asDateAndTime.
	self assert: history filteredWindowJumps first stop dateTime equals: '2025-09-01T11:56:34' asDateAndTime.
	self assert: history filteredWindowJumps first previous isNil.
	self assert: history filteredWindowJumps first next start dateTime equals: '2025-09-01T14:47:00' asDateAndTime.
	self assert: history filteredWindowJumps second start dateTime equals: '2025-09-01T14:47:00' asDateAndTime.
	self assert: history filteredWindowJumps second stop dateTime equals: '2025-09-01T14:48:24' asDateAndTime.
	self assert: history filteredWindowJumps second previous start dateTime equals: '2025-09-01T11:32:00' asDateAndTime.
	self assert: history filteredWindowJumps second next start dateTime equals: '2025-09-01T18:35:00' asDateAndTime.
	self assert: history filteredWindowJumps third start dateTime equals: '2025-09-01T18:35:00' asDateAndTime.
	self assert: history filteredWindowJumps third stop dateTime equals: '2025-09-01T18:47:00' asDateAndTime.
	self assert: history filteredWindowJumps third previous start dateTime equals: '2025-09-01T14:47:00' asDateAndTime.
	self assert: history filteredWindowJumps third next isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testBuildWindows [

	| windows filteredWindows debuggerOpening sourceDebugger |
	debuggerOpening := DSWindowOpenedRecord new
		                   windowId: 8;
		                   windowName: 'StDebugger';
		                   toolInfo: (DSToolInfo new
				                    toolClass: StDebugger;
				                    windowIdentityHash: 1;
				                    toolIdentityHash: 42).
	sourceDebugger := DSHaltHitRecord new windowId: 5.
	history windowsHistory: ({
			 ((DSRecordHistoryWindowKey new
				   windowId: 1;
				   windowName: 'playground') -> {
				  (DSWindowOpenedRecord new
					   dateTime: '2022-12-21T09:23:00' asDateAndTime;
					   windowId: 1;
					   windowName: 'StPlayground';
					   toolInfo: (DSToolInfo new
							    toolClass: StPlayground;
							    windowIdentityHash: 1;
							    toolIdentityHash: 42)).
				  DSDoItRecord new.
				  (DSMouseLeaveWindowRecord new dateTime: '2022-12-21T09:23:04' asDateAndTime) } asOrderedCollection).
			 ((DSRecordHistoryWindowKey new
				   windowId: 5;
				   windowName: 'playground') -> {
				  (DSMouseEnterWindowRecord new
					   windowId: 5;
					   dateTime: '2022-12-21T09:25:20' asDateAndTime).
				  DSPrintItRecord new.
				  DSClipboardPasteRecord new.
				  sourceDebugger.
				  (DSMouseLeaveWindowRecord new dateTime: '2022-12-21T09:27:03' asDateAndTime) } asOrderedCollection).
			 ((DSRecordHistoryWindowKey new
				   windowId: 8;
				   windowName: 'stDebugger') -> {
				  debuggerOpening.
				  (DSMouseEnterWindowRecord new dateTime: '2022-12-21T09:29:22' asDateAndTime).
				  DSStepIntoRecord new.
				  (DSMouseLeaveWindowRecord new dateTime: '2022-12-21T10:17:04' asDateAndTime) } asOrderedCollection).
			 ((DSRecordHistoryWindowKey new windowId: -1) -> {
				  (DSMouseEnterWindowRecord new windowId: -1).
				  DSClipboardCopyRecord new.
				  DSMouseLeaveWindowRecord new } asOrderedCollection) } as: IdentityDictionary).
	history events: {
			DSDoItRecord new.
			sourceDebugger.
			DSClipboardCopyRecord new.
			debuggerOpening } asOrderedCollection.

	history buildWindows.
	windows := history windows groupedBy: #windowId.
	filteredWindows := history filteredWindows groupedBy: #windowId.

	self assert: windows size equals: 4.
	self assert: (windows at: 1) first name equals: 'StPlayground'.
	self assert: (windows at: 1) first events size equals: 3.
	self assert: (windows at: 5) first name equals: 5.
	self assert: (windows at: 5) first events size equals: 5.
	self assert: (windows at: 8) first name equals: 'StDebugger'.
	self assert: (windows at: 8) first events size equals: 4.
	self assert: (windows at: -1) first name equals: -1.
	self assert: (windows at: -1) first events size equals: 3.

	self assert: filteredWindows size equals: 2.
	self assert: (windows at: 1) first name equals: 'StPlayground'.
	self assert: (windows at: 8) first name equals: 'StDebugger'.
]

{ #category : 'tests' }
DSRecordHistoryTest >> testCollectScrollingPeriods [

	| scrollList |
	history events: {
			(DSMouseEnterWindowRecord new
				 dateTime: '2026-03-25T10:01:17' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:02:44' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:06:08' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:09:23' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:13:41' asDateAndTime;
				 windowId: 1).
			(DSMouseLeaveWindowRecord new
				 dateTime: '2026-03-25T10:20:16' asDateAndTime;
				 windowId: 1).
			(DSMouseEnterWindowRecord new
				 dateTime: '2026-03-25T10:21:41' asDateAndTime;
				 windowId: 2).
			(DSDoItRecord new
				 dateTime: '2026-03-25T10:26:09' asDateAndTime;
				 windowId: 2).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:13:41' asDateAndTime;
				 windowId: 2).
			(DSStepIntoRecord new
				 dateTime: '2026-03-25T10:14:01' asDateAndTime;
				 windowId: 2) }.

	scrollList := history collectScrollingPeriods.

	self assert: scrollList size equals: 2.
	self assert: scrollList first key equals: {
			'2026-03-25T10:02:44' asDateAndTime.
			'2026-03-25T10:13:41' asDateAndTime }.
	self assert: scrollList first value equals: 1.
	self assert: scrollList second key equals: {
			'2026-03-25T10:13:41' asDateAndTime.
			'2026-03-25T10:13:41' asDateAndTime }.
	self assert: scrollList second value equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testCollectTimeDiscrepancies [

	| deltaDict |
	history events: {
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:02:44' asDateAndTime).
			(DSDoItRecord new dateTime: '2024-09-23T15:02:47' asDateAndTime).
			(DSStepIntoRecord new dateTime: '2024-09-23T15:02:54' asDateAndTime).
			(DSDebugItRecord new dateTime: '2024-09-23T15:02:56' asDateAndTime).
			(DSMouseLeaveWindowRecord new dateTime: '2024-09-23T15:03:00' asDateAndTime).
			(DSWindowClosedRecord new dateTime: '2024-09-23T15:03:03' asDateAndTime).
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:06:07' asDateAndTime).
			(DSPrintItRecord new dateTime: '2024-09-23T15:06:10' asDateAndTime).
			(DSClipboardCopyRecord new dateTime: '2024-09-23T15:06:26' asDateAndTime).
			(DSMethodRemovedRecord new dateTime: '2024-09-23T15:06:30' asDateAndTime) }.

	deltaDict := history collectTimeDiscrepancies.

	self assert: deltaDict size equals: 3.
	self assert: deltaDict first value equals: (Duration seconds: 7).
	self assert: deltaDict first key first class equals: DSDoItRecord.
	self assert: deltaDict first key second class equals: DSStepIntoRecord.
	self assert: deltaDict second value equals: (Duration seconds: 184).
	self assert: deltaDict second key first class equals: DSWindowClosedRecord.
	self assert: deltaDict second key second class equals: DSMouseEnterWindowRecord.
	self assert: deltaDict third value equals: (Duration seconds: 16).
	self assert: deltaDict third key first class equals: DSPrintItRecord.
	self assert: deltaDict third key second class equals: DSClipboardCopyRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testComputeIdleTime [

	history events: {
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:02:44' asDateAndTime).
			(DSDoItRecord new dateTime: '2024-09-23T15:02:47' asDateAndTime) }.

	self assert: history computeIdleTime equals: 0.

	history events: {
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:02:44' asDateAndTime).
			(DSDoItRecord new dateTime: '2024-09-23T15:02:47' asDateAndTime).
			(DSStepIntoRecord new dateTime: '2024-09-23T15:02:54' asDateAndTime).
			(DSDebugItRecord new dateTime: '2024-09-23T15:02:56' asDateAndTime).
			(DSMouseLeaveWindowRecord new dateTime: '2024-09-23T15:03:00' asDateAndTime).
			(DSWindowClosedRecord new dateTime: '2024-09-23T15:03:03' asDateAndTime).
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:06:07' asDateAndTime).
			(DSPrintItRecord new dateTime: '2024-09-23T15:06:10' asDateAndTime).
			(DSClipboardCopyRecord new dateTime: '2024-09-23T15:06:26' asDateAndTime).
			(DSMethodRemovedRecord new dateTime: '2024-09-23T15:06:30' asDateAndTime) }.

	self assert: history computeIdleTime equals: 7 + 184 + 16
]

{ #category : 'tests' }
DSRecordHistoryTest >> testCountDebugActions [

	history events: {
			DSMouseEnterWindowRecord new.
			DSMouseLeaveWindowRecord new.
			DSDoItRecord new.
			DSStepIntoRecord new.
			DSDoItAndGoRecord new.
			DSDebugItRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSHaltChangeRecord new.
			DSPrintItRecord new.
			DSPrintItRecord new.
			DSReturnValue new } asOrderedCollection.
			
	self assert: history countDebugActions equals: 9
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDateTime [

	history events: self getRecordsExample.
	self assert: history dateTime equals: '2000-05-07T15:02:44' asDateAndTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointAdds [

	history events: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name) } asOrderedCollection.
	self assert: history debugPointAdds equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointEvents [

	| debugPointEvents |
	history events: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name) } asOrderedCollection.

	debugPointEvents := history debugPointEvents.

	self assert: debugPointEvents size equals: 2.
	self assert: debugPointEvents first class equals: DSBreakDebugPointEventRecord.
	self assert: debugPointEvents first eventName equals: DebugPointHit name.
	self assert: debugPointEvents second class equals: DSBreakDebugPointEventRecord.
	self assert: debugPointEvents second eventName equals: DebugPointAdded name
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointEventsSelection [

	| debugPointEvents |
	history events: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name). 
			(DSBreakDebugPointEventRecord new eventName: DebugPointRemoved name). 
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name). } asOrderedCollection.

	debugPointEvents := history debugPointEvents: DebugPointAdded name.

	self assert: debugPointEvents size equals: 2.
	self assert: debugPointEvents first class equals: DSBreakDebugPointEventRecord.
	self assert: debugPointEvents first eventName equals: DebugPointAdded name.
	self assert: debugPointEvents second class equals: DSBreakDebugPointEventRecord.
	self assert: debugPointEvents second eventName equals: DebugPointAdded name
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointHit [

	history events: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name) } asOrderedCollection.
	self assert: history debugPointHit equals: 1
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDebugPointRemoved [

	history events: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointRemoved name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointRemoved name) } asOrderedCollection.
	self assert: history debugPointRemoved equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testDetectTimeDiscrepancies [

	history events: self getRecordsExample.
	self assert: history detectTimeDiscrepancies equals: 1320.
]

{ #category : 'tests' }
DSRecordHistoryTest >> testEstimateSourceEventOfFrom [

	| exampleRecord recordList result |
	exampleRecord := DSWindowOpenedRecord new.
	recordList := {
		              exampleRecord.
		              DSDoItRecord new.
		              DSWindowActivatedRecord new }.

	result := history estimateSourceEventOf: exampleRecord from: recordList.
	self assert: result isNil.

	recordList := {
		              DSBreakDebugPointEventRecord new.
		              DSDebugItRecord new.
		              (DSHaltHitRecord new windowId: 36).
		              DSClipboardPasteRecord new.
		              DSMouseEnterWindowRecord new.
		              DSPrintItRecord new.
		              exampleRecord.
		              DSDoItRecord new.
		              DSWindowActivatedRecord new }.

	result := history estimateSourceEventOf: exampleRecord from: recordList.
	self assert: result class equals: DSHaltHitRecord.
	self assert: result windowId equals: 36.

	recordList := {
		              DSPrintItRecord new.
		              DSStepIntoRecord new.
		              (DSDoItRecord new windowId: 67).
		              DSClipboardPasteRecord new.
		              DSMouseEnterWindowRecord new.
		              exampleRecord.
		              DSDoItRecord new.
		              DSWindowActivatedRecord new }.

	result := history estimateSourceEventOf: exampleRecord from: recordList.
	self assert: result class equals: DSDoItRecord.
	self assert: result windowId equals: 67.

	recordList := {
		              DSMouseEnterWindowRecord new.
		              DSMouseLeaveWindowRecord new.
		              DSSendersRecord new.
		              (DSBrowseRecord new windowId: 26).
		              exampleRecord.
		              DSDoItRecord new.
		              DSWindowActivatedRecord new }.

	result := history estimateSourceEventOf: exampleRecord from: recordList.
	self assert: result class equals: DSBrowseRecord.
	self assert: result windowId equals: 26
]

{ #category : 'tests' }
DSRecordHistoryTest >> testEventsAfter [

	| listOfEvents |
	history events: self getRecordsExample.
	listOfEvents := history eventsAfter: '2000-05-07T15:06:05' asDateAndTime.

	self assert: listOfEvents size equals: 2.
	self assert: listOfEvents first class equals: DSDoItRecord.
	self assert: listOfEvents second class equals: DSMouseLeaveWindowRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testEventsBefore [

	| listOfEvents |
	history events: self getRecordsExample.
	listOfEvents := history eventsBefore: '2000-05-07T15:13:47' asDateAndTime.

	self assert: listOfEvents size equals: 3.
	self assert: listOfEvents first class equals: DSMouseEnterWindowRecord.
	self assert: listOfEvents second class equals: DSMouseLeaveWindowRecord.
	self assert: listOfEvents third class equals: DSMouseEnterWindowRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testExecutedCode [

	history events: {
			DSMouseEnterWindowRecord new.
			DSDoItRecord new.
			DSStepIntoRecord new.
			DSDoItAndGoRecord new.
			DSDebugItRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSPrintItRecord new.
			DSPrintItRecord new.
			DSReturnValue new } asOrderedCollection.
	self assert: history executedCode equals: 5
]

{ #category : 'tests' }
DSRecordHistoryTest >> testFindSourceEventLikeForRecordIn [

	| exampleRecord recordList possibleSourceEvents result |
	possibleSourceEvents := {
		                        DSDebugItRecord.
		                        DSBreakDebugPointEventRecord }.
	exampleRecord := DSWindowOpenedRecord new.
	recordList := {
		              DSWindowOpenedRecord new.
		              DSDoItRecord new.
		              exampleRecord.
		              DSWindowActivatedRecord new }.

	result := history findSourceEventLike: possibleSourceEvents forRecord: exampleRecord in: recordList.
	self assert: result isNil.

	recordList := {
		              DSDebugItRecord new.
		              DSClipboardCopyRecord new.
		              DSDoItRecord new.
		              exampleRecord.
		              DSWindowActivatedRecord new }.

	result := history findSourceEventLike: possibleSourceEvents forRecord: exampleRecord in: recordList.
	self assert: result class equals: DSDebugItRecord.

	recordList := {
		              DSStepIntoRecord new.
		              DSMouseEnterWindowRecord new.
		              (DSBreakDebugPointEventRecord new eventName: 'DebugPointAdded').
		              exampleRecord.
		              DSClipboardPasteRecord new }.

	result := history findSourceEventLike: possibleSourceEvents forRecord: exampleRecord in: recordList.
	self assert: result isNil.

	recordList := {
		              DSDoItRecord new.
		              DSMouseEnterWindowRecord new.
		              exampleRecord.
		              DSClipboardPasteRecord new.
		              DSMouseLeaveWindowRecord new }.

	result := history findSourceEventLike: possibleSourceEvents forRecord: exampleRecord in: recordList.
	self assert: result isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testFindWindowRecordKeyForID [

	| windowKey |
	windowKey := history findWindowRecordKeyForID: 1.
	self assert: windowKey class equals: DSRecordHistoryWindowKey.
	self assert: windowKey windowId equals: 1.
	
	history windowsHistory: ({ (DSRecordHistoryWindowKey new windowId:2) -> 'someRecords' } as: IdentityDictionary).

	windowKey := history findWindowRecordKeyForID: 2.
	self assert: windowKey class equals: DSRecordHistoryWindowKey.
	self assert: windowKey windowId equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testFixMissingWindowIds [

	history events: {
			DSDoItRecord new.
			(DSMouseEnterWindowRecord new windowId: 1).
			DSMethodAddedRecord new.
			(DSMethodRemovedRecord new windowId: 1).
			(DSMouseLeaveWindowRecord new windowId: 1).
			DSReturnValue new.
			(DSWindowOpenedRecord new
				 windowId: 3;
				 windowName: 'TestWindow').
			DSStepIntoRecord new.
			(DSMouseLeaveWindowRecord new windowId: 3).
			DSPrintItRecord new } asOrderedCollection.

	history fixMissingWindowIds.

	self assert: history events first windowId equals: -1.
	self assert: history events third windowId equals: 1.
	self assert: (history events at: 6) windowId equals: -1.
	self assert: (history events at: 8) windowId equals: 3.
	self assert: (history events at: 10) windowId equals: -1.

	self assert: history windowNames size equals: 1.
	self assert: (history windowNames at: 3) equals: 'TestWindow'
]

{ #category : 'tests' }
DSRecordHistoryTest >> testFixWindowRecordKeysNames [

	| windowsHistory |
	history windowNames: {
			(1 -> 'playGroundWindow').
			(53 -> 'browserWindow') } asDictionary.
	history windowsHistory: ({
			 ((DSRecordHistoryWindowKey new windowId: 1) -> 'someRecords').
			 ((DSRecordHistoryWindowKey new windowId: 2) -> 'someRecords').
			 ((DSRecordHistoryWindowKey new windowId: 53) -> 'someRecords') } as: IdentityDictionary).

	history fixWindowRecordKeysNames.

	windowsHistory := history windowsHistory.
	self assert: windowsHistory size equals: 3.
	self assert: (windowsHistory keys detect: [ :k | k windowId = 1 ]) windowName equals: 'playGroundWindow'.
	self assert: (windowsHistory keys detect: [ :k | k windowId = 53 ]) windowName equals: 'browserWindow'.
	self assert: (windowsHistory keys detect: [ :k | k windowId = 2 ]) windowName isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testGetSumOfScrollingPeriods [

	| scrollList |
	history events: {
			(DSMouseEnterWindowRecord new
				 dateTime: '2026-03-25T10:01:17' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:02:44' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:06:08' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:09:23' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:13:41' asDateAndTime;
				 windowId: 1).
			(DSMouseLeaveWindowRecord new
				 dateTime: '2026-03-25T10:20:16' asDateAndTime;
				 windowId: 1).
			(DSMouseEnterWindowRecord new
				 dateTime: '2026-03-25T10:21:41' asDateAndTime;
				 windowId: 2).
			(DSDoItRecord new
				 dateTime: '2026-03-25T10:26:09' asDateAndTime;
				 windowId: 2).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:13:41' asDateAndTime;
				 windowId: 2).
			(DSStepIntoRecord new
				 dateTime: '2026-03-25T10:14:01' asDateAndTime;
				 windowId: 2).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:26:35' asDateAndTime;
				 windowId: 1).
			(DSScrollingRecord new
				 dateTime: '2026-03-25T10:27:39' asDateAndTime;
				 windowId: 1) }.


	scrollList := history getSumOfScrollingPeriods.

	self assert: scrollList size equals: 2.
	self assert: (scrollList at: 1) equals: (Duration seconds: 721).
	self assert: (scrollList at: 2) equals: (Duration seconds: 0)
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMergeContinuousEvents [

	| newRecordList |
	history events: {
			DSMouseEnterWindowRecord new.
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSMethodAddedRecord new.
			DSReturnValue new.
			DSReturnValue new.
			DSReturnValue new.
			DSMouseLeaveWindowRecord new.
			DSWindowClosedRecord new } asOrderedCollection.


	newRecordList := history mergeContinuousEvents.

	self assert: newRecordList size equals: 7.
	self assert: newRecordList first size equals: 2.
	self assert: newRecordList first first class equals: DSMouseEnterWindowRecord.
	self assert: newRecordList second first class equals: DSMethodAddedRecord.
	self assert: newRecordList third first class equals: DSMethodRemovedRecord.
	self assert: (newRecordList at: 4) first class equals: DSMethodAddedRecord.
	self assert: (newRecordList at: 5) size equals: 3.
	self assert: (newRecordList at: 5) first class equals: DSReturnValue.
	self assert: (newRecordList at: 6) first class equals: DSMouseLeaveWindowRecord.
	self assert: (newRecordList at: 7) first class equals: DSWindowClosedRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMergeFilteredWindowJumps [

	| window1 window2 window3 previousWindowActivity nextWindowActivity |
	window1 := DSWindowRecord new.
	window2 := DSWindowRecord new.
	window3 := DSWindowRecord new.

	history filteredWindowJumps: {
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T05:30:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T06:15:03' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSDoItRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window2).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T09:26:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T09:26:00' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSClipboardCopyRecord new.
						 DSStepIntoRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window1).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T014:47:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T14:48:24' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSStepIntoRecord new.
						 DSPrintItRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window1).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T19:30:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T19:34:57' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window3).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T20:35:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T20:47:00' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSDoItRecord new.
						 DSPrintItRecord new.
						 DSClipboardCopyRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window3).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T21:32:00' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T21:56:34' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSDoItRecord new.
						 DSInspectItRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window3).
			(DSWindowActivityRecord new
				 start: (DSMouseEnterWindowRecord new dateTime: '2025-09-01T22:01:56' asDateAndTime);
				 stop: (DSMouseLeaveWindowRecord new dateTime: '2025-09-01T22:09:15' asDateAndTime);
				 events: {
						 DSMouseEnterWindowRecord new.
						 DSMouseLeaveWindowRecord new };
				 window: window2) } asOrderedCollection.

	previousWindowActivity := nil.
	history filteredWindowJumps do: [ :period |
			period previous: previousWindowActivity.
			previousWindowActivity := period ].

	nextWindowActivity := nil.
	history filteredWindowJumps reverseDo: [ :period |
			period next: nextWindowActivity.
			nextWindowActivity := period ].

	history mergeFilteredWindowJumps.

	self assert: history mergedWindowJumps size equals: 4.
	self assert: history mergedWindowJumps first class equals: DSWindowActivityRecord.
	self assert: history mergedWindowJumps first start dateTime equals: '2025-09-01T05:30:00' asDateAndTime.
	self assert: history mergedWindowJumps first stop dateTime equals: '2025-09-01T06:15:03' asDateAndTime.
	self assert: history mergedWindowJumps first previous isNil.
	self assert: history mergedWindowJumps first next start dateTime equals: '2025-09-01T09:26:00' asDateAndTime.
	self assert: history mergedWindowJumps first events size equals: 3.
	self assert: history mergedWindowJumps second start dateTime equals: '2025-09-01T09:26:00' asDateAndTime.
	self assert: history mergedWindowJumps second stop dateTime equals: '2025-09-01T14:48:24' asDateAndTime.
	self assert: history mergedWindowJumps second previous start dateTime equals: '2025-09-01T05:30:00' asDateAndTime.
	self assert: history mergedWindowJumps second next start dateTime equals: '2025-09-01T19:30:00' asDateAndTime.
	self assert: history mergedWindowJumps second events size equals: 8.
	self assert: history mergedWindowJumps third start dateTime equals: '2025-09-01T19:30:00' asDateAndTime.
	self assert: history mergedWindowJumps third stop dateTime equals: '2025-09-01T21:56:34' asDateAndTime.
	self assert: history mergedWindowJumps third previous start dateTime equals: '2025-09-01T09:26:00' asDateAndTime.
	self assert: history mergedWindowJumps third next start dateTime equals: '2025-09-01T22:01:56' asDateAndTime.
	self assert: history mergedWindowJumps third events size equals: 11.
	self assert: history mergedWindowJumps last start dateTime equals: '2025-09-01T22:01:56' asDateAndTime.
	self assert: history mergedWindowJumps last stop dateTime equals: '2025-09-01T22:09:15' asDateAndTime.
	self assert: history mergedWindowJumps last previous start dateTime equals: '2025-09-01T19:30:00' asDateAndTime.
	self assert: history mergedWindowJumps last next isNil.
	self assert: history mergedWindowJumps last events size equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMethodsAdded [

	history events: {
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSMethodAddedRecord new.
			DSReturnValue new } asOrderedCollection.
	self assert: history methodsAdded equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMethodsModified [

	history events: {
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			DSMethodModifiedRecord new.
			DSMethodRemovedRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSReturnValue new } asOrderedCollection.
	self assert: history methodsModified equals: 1
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMethodsModifiedEvents [

	| methodModifiedEvents |
	history events: {
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			(DSMethodModifiedRecord new windowId: 23).
			DSMethodRemovedRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSReturnValue new.
			(DSMethodModifiedRecord new windowId: 54) } asOrderedCollection.

	methodModifiedEvents := history methodsModifiedEvents.
	self assert: methodModifiedEvents size equals: 2.
	self assert: methodModifiedEvents first class equals: DSMethodModifiedRecord.
	self assert: methodModifiedEvents first windowId equals: 23.
	self assert: methodModifiedEvents second class equals: DSMethodModifiedRecord.
	self assert: methodModifiedEvents second windowId equals: 54
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMethodsRemoved [

	history events: {
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSStepIntoRecord new.
			DSReturnValue new } asOrderedCollection.
	self assert: history methodsRemoved equals: 1
]

{ #category : 'tests' }
DSRecordHistoryTest >> testName [

	history tag: '42'.
	history user: 'pierre dupont'.
	history taskName: 'TaskOfDebugging'.

	self assert: history name equals: 'pierre dupont: TaskOfDebugging(42)'
]

{ #category : 'tests' }
DSRecordHistoryTest >> testNumberOfSteps [

	history events: {
			DSProceedRecord new.
			DSMouseEnterWindowRecord new.
			DSReturnValue new.
			DSStepOverRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name) } asOrderedCollection.
	self assert: history numberOfSteps equals: 3
]

{ #category : 'tests' }
DSRecordHistoryTest >> testProcessRecords [

	| recordList |
	recordList := {
		              (DSMouseEnterWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T09:00:00' asDateAndTime).
		              (DSMouseLeaveWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T09:03:04' asDateAndTime).
		              (DSWindowOpenedRecord new
			               windowId: 2;
			               windowName: 'Inspector';
			               dateTime: '2024-07-04T09:08:32' asDateAndTime).
		              (DSMouseEnterWindowRecord new
			               windowId: 2;
			               dateTime: '2024-07-04T09:11:06' asDateAndTime).
		              (DSDoItRecord new
			               windowId: 2;
			               dateTime: '2024-07-04T09:15:56' asDateAndTime).
		              (DSMouseLeaveWindowRecord new
			               windowId: 2;
			               dateTime: '2024-07-04T09:19:14' asDateAndTime).
		              (DSMouseEnterWindowRecord new
			               windowId: 3;
			               dateTime: '2024-07-04T09:23:30' asDateAndTime).
		              (DSStepIntoRecord new
			               windowId: 3;
			               dateTime: '2024-07-04T09:32:43' asDateAndTime).
		              (DSMouseLeaveWindowRecord new
			               windowId: 3;
			               dateTime: '2024-07-04T09:35:28' asDateAndTime).
		              (DSMouseEnterWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T10:02:44' asDateAndTime).
		              (DSClipboardCopyRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T10:17:08' asDateAndTime).
		              (DSMouseLeaveWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T10:26:12' asDateAndTime) } asOrderedCollection.


	history processRecords: recordList.

	self assert: history events size equals: 12.
	self assert: history windows size equals: 3.
	self assert: history windowsHistory size equals: 3.
	self assert: history filteredWindows size equals: 3.
	self assert: history windowJumps size equals: 4.
	self assert: history filteredWindowJumps isEmpty 
]

{ #category : 'tests' }
DSRecordHistoryTest >> testProcessRecordsOneWindow [

	| recordList |
	recordList := {
		              (DSMouseEnterWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T09:00:00' asDateAndTime).
		              (DSDoItAndGoRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T09:03:04' asDateAndTime).
		              (DSClipboardCopyRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T10:17:08' asDateAndTime).
		              (DSMouseLeaveWindowRecord new
			               windowId: 1;
			               dateTime: '2024-07-04T10:26:12' asDateAndTime) } asOrderedCollection.


	history processRecords: recordList.

	self assert: history events size equals: 4.
	self assert: history windows size equals: 1.
	self assert: history windowsHistory size equals: 1.
	self assert: history filteredWindows size equals: 1.
	self assert: history windowJumps size equals: 1.
	self assert: history filteredWindowJumps size equals: 1
]

{ #category : 'tests' }
DSRecordHistoryTest >> testReconstructSourcesOfDebuggerOpenings [

	| openWindow1 openWindow2 openWindow3 sourceEvent1 sourceEvent2 |
	openWindow1 := DSMouseEnterWindowRecord new dateTime: '2015-11-04T08:57:14' asDateAndTime.
	openWindow2 := DSWindowOpenedRecord new dateTime: '2015-11-04T10:23:38' asDateAndTime.
	openWindow3 := DSWindowOpenedRecord new dateTime: '2015-11-04T09:45:09' asDateAndTime.

	history windows: {
			(DSWindowRecord new
				 events: { openWindow1 };
				 toolInfo: (DSToolInfo new toolClass: StDebugger)).
			(DSWindowRecord new
				 events: { (DSWindowOpenedRecord new dateTime: '2015-11-04T09:12:09' asDateAndTime) };
				 toolInfo: (DSToolInfo new toolClass: IceTipRepositoryBrowser)).
			(DSWindowRecord new
				 events: { openWindow3 };
				 toolInfo: (DSToolInfo new toolClass: StDebugger)).
			(DSWindowRecord new
				 events: { openWindow2 };
				 toolInfo: (DSToolInfo new toolClass: StDebugger)) }.

	sourceEvent1 := DSDebugItRecord new windowId: 1.
	sourceEvent2 := DSPrintItRecord new windowId: 3.

	history events: {
			DSDoItRecord new.
			sourceEvent1.
			DSStepIntoRecord new.
			openWindow1.
			openWindow3.
			DSMouseLeaveWindowRecord new.
			DSMouseEnterWindowRecord new.
			sourceEvent2.
			DSBrowseRecord new.
			DSMethodAddedRecord new.
			openWindow2 }.

	history reconstructSourcesOfDebuggerOpenings.

	self assert: history windows size equals: 4.
	self assert: history windows first sourceEvent equals: sourceEvent1.
	self assert: history windows second sourceEvent isNil.
	self assert: history windows third sourceEvent isNil.
	self assert: (history windows at: 4) sourceEvent equals: sourceEvent2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testReconstructWindowsToolInfo [

	| toolInfoExample |
	toolInfoExample := DSToolInfo new
		                   toolClass: StPlayground;
		                   windowIdentityHash: 1;
		                   toolIdentityHash: 42.

	history events: {
			(DSMouseEnterWindowRecord new toolInfo: toolInfoExample).
			DSDebugItRecord new.
			(DSMouseEnterWindowRecord new toolInfo: nil) }.

	history windows: {
			(DSWindowRecord new events: { (DSMouseEnterWindowRecord new windowId: 1) }).
			(DSWindowRecord new events: { (DSPrintItRecord new windowId: -1) }).
			(DSWindowRecord new events: { (DSStepIntoRecord new windowId: 2) }) }.

	history reconstructWindowsToolInfo.

	self assert: history windows size equals: 3.
	self assert: history windows first toolInfo equals: toolInfoExample.
	self assert: history windows second toolInfo isNil.
	self assert: history windows third toolInfo isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testStartTime [

	history events: self getRecordsExample.
	self assert: history startTime equals: '15:02:44' asTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testStopTime [

	history events: self getRecordsExample.
	self assert: history stopTime equals: '15:24:44' asTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testTimeTaken [

	history events: {
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:02:44' asDateAndTime).
			(DSDoItRecord new dateTime: '2024-09-23T15:02:47' asDateAndTime).
			(DSStepIntoRecord new dateTime: '2024-09-23T15:02:54' asDateAndTime).
			(DSDebugItRecord new dateTime: '2024-09-23T15:02:56' asDateAndTime).
			(DSMouseLeaveWindowRecord new dateTime: '2024-09-23T15:03:00' asDateAndTime).
			(DSWindowClosedRecord new dateTime: '2024-09-23T15:03:03' asDateAndTime).
			(DSMouseEnterWindowRecord new dateTime: '2024-09-23T15:06:07' asDateAndTime).
			(DSPrintItRecord new dateTime: '2024-09-23T15:06:10' asDateAndTime).
			(DSClipboardCopyRecord new dateTime: '2024-09-23T15:06:26' asDateAndTime).
			(DSMethodRemovedRecord new dateTime: '2024-09-23T15:06:30' asDateAndTime) }.

	self assert: history timeTaken equals: 3 * 60 + 46 - (7 + 184 + 16)
]

{ #category : 'tests' }
DSRecordHistoryTest >> testToolInfosFor [

	| toolInfo |
	history windows: { (DSWindowRecord new
			 toolInfo: (DSToolInfo new
					  toolClass: StPlayground;
					  windowIdentityHash: 1;
					  toolIdentityHash: 42);
			 events: { (DSWindowOpenedRecord new windowId: 1) }) } asOrderedCollection.

	toolInfo := history toolInfosFor: 1.
	self assert: toolInfo class equals: DSToolInfo.
	self assert: toolInfo toolClass equals: StPlayground.
	self assert: toolInfo toolIdentityHash equals: 42.
	self assert: toolInfo windowIdentityHash equals: 1.

	toolInfo := history toolInfosFor: 98.
	self assert: toolInfo isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testValidateWindows [

	| erroneousWindows currentWindow |
	history windows: {
			(DSWindowRecord new events: {
					 (DSWindowOpenedRecord new dateTime: '2015-11-04T09:45:09' asDateAndTime).
					 (DSDoItRecord new dateTime: '2015-11-04T14:28:15' asDateAndTime).
					 (DSClipboardPasteRecord new dateTime: '2015-11-04T09:45:28' asDateAndTime).
					 (DSMethodAddedRecord new dateTime: '2015-11-04T09:56:43' asDateAndTime).
					 (DSMouseLeaveWindowRecord new dateTime: '2015-11-04T09:45:56' asDateAndTime) }).
			(DSWindowRecord new events: {
					 (DSClipboardCopyRecord new dateTime: '2015-11-04T09:45:15' asDateAndTime).
					 (DSDoItAndGoRecord new dateTime: '2015-11-04T09:51:28' asDateAndTime).
					 (DSStepIntoRecord new dateTime: '2015-11-04T09:45:43' asDateAndTime).
					 (DSWindowClosedRecord new dateTime: '2015-11-04T09:45:56' asDateAndTime) }).
			(DSWindowRecord new events: {
					 (DSMouseEnterWindowRecord new dateTime: '2015-11-04T09:45:09' asDateAndTime).
					 (DSInspectItRecord new dateTime: '2015-11-04T09:45:15' asDateAndTime).
					 (DSDoItRecord new dateTime: '2015-11-04T09:45:28' asDateAndTime).
					 (DSHaltHitRecord new dateTime: '2015-11-04T09:45:43' asDateAndTime) }).
			(DSWindowRecord new events: { (DSStepThroughRecord new dateTime: '2015-11-04T09:45:15' asDateAndTime) }).
			(DSWindowRecord new events: {
					 (DSMouseEnterWindowRecord new dateTime: '2015-11-04T09:45:09' asDateAndTime).
					 (DSBrowseRecord new dateTime: '2015-11-04T09:45:15' asDateAndTime).
					 (DSMouseLeaveWindowRecord new dateTime: '2015-11-04T09:45:43' asDateAndTime) }) }.


	erroneousWindows := history validateWindows.

	self assert: erroneousWindows size equals: 5.

	currentWindow := erroneousWindows at: history windows first.
	self assert: currentWindow size equals: 2.
	self assert: currentWindow first class equals: DSDoItRecord.
	self assert: currentWindow second class equals: DSMethodAddedRecord.

	currentWindow := erroneousWindows at: history windows second.
	self assert: currentWindow size equals: 2.
	self assert: currentWindow first class equals: Association.
	self assert: currentWindow first key equals: #opening.
	self assert: currentWindow first value class equals: DSClipboardCopyRecord.
	self assert: currentWindow second class equals: DSDoItAndGoRecord.

	currentWindow := erroneousWindows at: history windows third.
	self assert: currentWindow size equals: 1.
	self assert: currentWindow first class equals: Association.
	self assert: currentWindow first key equals: #closing.
	self assert: currentWindow first value class equals: DSHaltHitRecord.

	currentWindow := erroneousWindows at: (history windows at: 4).
	self assert: currentWindow size equals: 2.
	self assert: currentWindow first class equals: Association.
	self assert: currentWindow first key equals: #opening.
	self assert: currentWindow first value class equals: DSStepThroughRecord.
	self assert: currentWindow second class equals: Association.
	self assert: currentWindow second key equals: #closing.
	self assert: currentWindow second value class equals: DSStepThroughRecord.

	currentWindow := erroneousWindows at: (history windows at: 5).
	self assert: currentWindow isEmpty
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

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

	history records: self getRecordsExample.
	self assert: history absoluteTimeTaken equals: 22
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
DSRecordHistoryTest >> testBuildWindowHistory [

	| windowsHistory |
	history records: self getRecordsExample.
	history buildWindowHistory.
	windowsHistory := history windowsHistory.

	self assert: windowsHistory class equals: IdentityDictionary.
	self assert: windowsHistory size equals: 2.
	self flag: 'TODO'
]

{ #category : 'tests' }
DSRecordHistoryTest >> testBuildWindows [

	| windows |
	history records: self getRecordsExample.
	history windowsHistory: IdentityDictionary new.
	history buildWindows.
	windows := history windows.

	self assert: windows class equals: OrderedCollection.
	self assert: windows size equals: 0.
	self flag: 'TODO'
]

{ #category : 'tests' }
DSRecordHistoryTest >> testCollectTimeDiscrepancies [

	| deltaDict |
	history records: {
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
	self assert: deltaDict first value equals: 7 asDuration.
	self assert: deltaDict first key first class equals: DSDoItRecord.
	self assert: deltaDict first key second class equals: DSStepIntoRecord.
	self assert: deltaDict second value equals: 184 asDuration.
	self assert: deltaDict second key first class equals: DSWindowClosedRecord.
	self assert: deltaDict second key second class equals: DSMouseEnterWindowRecord.
	self assert: deltaDict third value equals: 16 asDuration.
	self assert: deltaDict third key first class equals: DSPrintItRecord.
	self assert: deltaDict third key second class equals: DSClipboardCopyRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testCountDebugActions [

	history records: {
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
DSRecordHistoryTest >> testDebugPointEvents [

	| debugPointEvents |
	history records: {
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
	history records: {
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

	history records: {
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name).
			DSMouseEnterWindowRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointAdded name) } asOrderedCollection.
	self assert: history debugPointHit equals: 1
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
DSRecordHistoryTest >> testDetectTimeDiscrepancies [

	history records: self getRecordsExample.
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
	history records: self getRecordsExample.
	listOfEvents := history eventsAfter: '2000-05-07T15:06:05' asDateAndTime.

	self assert: listOfEvents size equals: 2.
	self assert: listOfEvents first class equals: DSDoItRecord.
	self assert: listOfEvents second class equals: DSMouseLeaveWindowRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testEventsBefore [

	| listOfEvents |
	history records: self getRecordsExample.
	listOfEvents := history eventsBefore: '2000-05-07T15:13:47' asDateAndTime.

	self assert: listOfEvents size equals: 3.
	self assert: listOfEvents first class equals: DSMouseEnterWindowRecord.
	self assert: listOfEvents second class equals: DSMouseLeaveWindowRecord.
	self assert: listOfEvents third class equals: DSMouseEnterWindowRecord
]

{ #category : 'tests' }
DSRecordHistoryTest >> testExecutedCode [

	history records: {
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

	history records: {
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

	self assert: history records first windowId equals: -1.
	self assert: history records third windowId equals: 1.
	self assert: (history records at: 6) windowId equals: -1.
	self assert: (history records at: 8) windowId equals: 3.
	self assert: (history records at: 10) windowId equals: -1.

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
DSRecordHistoryTest >> testMethodsAdded [

	history records: {
			DSMouseEnterWindowRecord new.
			DSMethodAddedRecord new.
			DSMethodRemovedRecord new.
			DSMethodAddedRecord new.
			DSReturnValue new } asOrderedCollection.
	self assert: history methodsAdded equals: 2
]

{ #category : 'tests' }
DSRecordHistoryTest >> testMethodsModified [

	history records: {
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
	history records: {
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

	history records: {
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

	history records: {
			DSProceedRecord new.
			DSMouseEnterWindowRecord new.
			DSReturnValue new.
			DSStepOverRecord new.
			(DSBreakDebugPointEventRecord new eventName: DebugPointHit name) } asOrderedCollection.
	self assert: history numberOfSteps equals: 3
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
				 toolInfos: (DSToolInfo new toolClassName: 'StDebugger')).
			(DSWindowRecord new
				 events: { (DSWindowOpenedRecord new dateTime: '2015-11-04T09:12:09' asDateAndTime) };
				 toolInfos: (DSToolInfo new toolClassName: 'IceTipRepositoryBrowser')).
			(DSWindowRecord new
				 events: { openWindow3 };
				 toolInfos: (DSToolInfo new toolClassName: 'StDebugger')).
			(DSWindowRecord new
				 events: { openWindow2 };
				 toolInfos: (DSToolInfo new toolClassName: 'StDebugger')) }.

	sourceEvent1 := DSDebugItRecord new windowId: 1.
	sourceEvent2 := DSPrintItRecord new windowId: 3.

	history records: {
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
		                   toolClassName: #Playground;
		                   windowIdentityHash: 1;
		                   toolIdentityHash: 42.

	history records: {
			(DSMouseEnterWindowRecord new toolInfo: toolInfoExample).
			DSDebugItRecord new.
			(DSMouseEnterWindowRecord new toolInfo: nil) }.

	history windows: {
			(DSWindowRecord new events: { (DSMouseEnterWindowRecord new windowId: 1) }).
			(DSWindowRecord new events: { (DSPrintItRecord new windowId: -1) }).
			(DSWindowRecord new events: { (DSStepIntoRecord new windowId: 2) }) }.

	history reconstructWindowsToolInfo.

	self assert: history windows size equals: 3.
	self assert: history windows first toolInfos equals: toolInfoExample.
	self assert: history windows second toolInfos isNil.
	self assert: history windows third toolInfos isNil
]

{ #category : 'tests' }
DSRecordHistoryTest >> testStartTime [

	history records: self getRecordsExample.
	self assert: history startTime equals: '15:02:44' asTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testStopTime [

	history records: self getRecordsExample.
	self assert: history stopTime equals: '15:24:44' asTime
]

{ #category : 'tests' }
DSRecordHistoryTest >> testToolInfosFor [

	| toolInfo |
	history windows: { (DSWindowRecord new
			 toolInfos: (DSToolInfo new
					  toolClassName: #Playground;
					  windowIdentityHash: 1;
					  toolIdentityHash: 42);
			 events: { (DSWindowOpenedRecord new windowId: 1) }) } asOrderedCollection.

	toolInfo := history toolInfosFor: 1.
	self assert: toolInfo class equals: DSToolInfo.
	self assert: toolInfo toolClassName equals: #Playground.
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

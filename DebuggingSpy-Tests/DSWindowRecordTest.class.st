Class {
	#name : 'DSWindowRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSWindowRecordTest >> testBuildEvents [

	| windowRecord eventsCollection |
	windowRecord := DSWindowRecord new.

	eventsCollection := {
		                    (DSWindowOpenedRecord new
			                     windowName: 'Unknown window';
			                     windowId: 42;
			                     dateTime: '2008-01-22T16:00:25' asDateAndTime).
		                    (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:00:31' asDateAndTime).
		                    DSDoItAndGoRecord new.
		                    DSClipboardCopyRecord new.
		                    (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:01:10' asDateAndTime).
		                    (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:04:31' asDateAndTime).
		                    DSBrowseRecord new.
		                    (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:04:45' asDateAndTime).
		                    DSPrintItRecord new } asOrderedCollection.

	windowRecord buildEvents: eventsCollection.

	self assert: windowRecord events size equals: 9.
	self assert: windowRecord name equals: 'Unknown window'.
	self assert: windowRecord type equals: 'Application'.
	self assert: windowRecord activePeriods size equals: 2.

	windowRecord := DSWindowRecord new.

	eventsCollection := {
		                    (DSWindowOpenedRecord new
			                     windowName: 'Debugger';
			                     windowId: 42;
			                     dateTime: '2008-01-22T16:00:25' asDateAndTime).
		                    (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:00:31' asDateAndTime).
		                    DSDoItAndGoRecord new.
		                    DSClipboardCopyRecord new.
		                    (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:01:10' asDateAndTime) } asOrderedCollection.

	windowRecord buildEvents: eventsCollection.

	self assert: windowRecord events size equals: 5.
	self assert: windowRecord name equals: 'Debugger'.
	self assert: windowRecord type equals: 'Debugger'.
	self assert: windowRecord activePeriods size equals: 1
]

{ #category : 'tests' }
DSWindowRecordTest >> testComputeActivePeriods [

	| windowRecord activePeriods |
	windowRecord := DSWindowRecord new events: {
			                (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T15:57:14' asDateAndTime).
			                DSStepIntoRecord new.
			                (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:00:25' asDateAndTime).
			                DSDoItAndGoRecord new.
			                DSClipboardCopyRecord new.
			                (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:01:10' asDateAndTime).
			                (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:04:31' asDateAndTime).
			                DSBrowseRecord new.
			                (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:04:45' asDateAndTime).
			                DSPrintItRecord new.
			                (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:04:57' asDateAndTime).
			                (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:05:08' asDateAndTime).
			                (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:05:29' asDateAndTime) } asOrderedCollection.

	windowRecord computeActivePeriods.
	activePeriods := windowRecord activePeriods.

	self assert: activePeriods size equals: 3.
	self assert: activePeriods first start dateTime equals: '2008-01-22T16:00:25' asDateAndTime.
	self assert: activePeriods first stop dateTime equals: '2008-01-22T16:01:10' asDateAndTime.
	self assert: activePeriods first events size equals: 4.
	self assert: activePeriods first window equals: windowRecord.
	self assert: activePeriods second start dateTime equals: '2008-01-22T16:04:31' asDateAndTime.
	self assert: activePeriods second stop dateTime equals: '2008-01-22T16:04:45' asDateAndTime.
	self assert: activePeriods second events size equals: 3.
	self assert: activePeriods second window equals: windowRecord.
	self assert: activePeriods third start dateTime equals: '2008-01-22T16:04:57' asDateAndTime.
	self assert: activePeriods third stop dateTime equals: '2008-01-22T16:05:08' asDateAndTime.
	self assert: activePeriods third events size equals: 2.
	self assert: activePeriods third window equals: windowRecord
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsBrowser [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isBrowser.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'ClyFullBrowserMorph').
	self assert: windowRecord isBrowser
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsCritiqueBrowser [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isCritiqueBrowser.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'StCritiquePackageSelectorPresenter').
	self assert: windowRecord isCritiqueBrowser
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsDebugPointBrowser [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isDebugPointBrowser.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'DebugPointBrowserPresenter').
	self assert: windowRecord isDebugPointBrowser
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsDebugger [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isDebugger.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'StDebugger').
	self assert: windowRecord isDebugger
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsEpicea [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isEpicea.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'EpUnifiedBrowserPresenter').
	self assert: windowRecord isEpicea
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsIceberg [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isIceberg.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'IceTipRepositoryBrowser').
	self assert: windowRecord isIceberg
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsInspector [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isInspector.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'StInspectorPresenter').
	self assert: windowRecord isInspector
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsPlayground [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isPlayground.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'StPlaygroundPresenter').
	self assert: windowRecord isPlayground
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsQueryTool [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isQueryTool.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'ClyQueryBrowserMorph').
	self assert: windowRecord isQueryTool
]

{ #category : 'tests' }
DSWindowRecordTest >> testIsRewriter [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self deny: windowRecord isRewriter.

	windowRecord := DSWindowRecord new toolInfos: (DSToolInfo new toolClassName: 'StRewriterExpressionFinderPresenter').
	self assert: windowRecord isRewriter
]

{ #category : 'tests' }
DSWindowRecordTest >> testPrintOn [

	| windowRecord printed |
	windowRecord := DSWindowRecord new
		                name: 'aBeautifulPlayground';
		                toolInfos: (DSToolInfo new toolClassName: 'Playground');
		                type: 'MyType'.
	printed := String streamContents: [ :stream | windowRecord printOn: stream ].
	self assert: printed equals: '[Playground] aBeautifulPlayground'.

	windowRecord := DSWindowRecord new
		                name: 'SomeName';
		                type: 'MyType'.
	printed := String streamContents: [ :stream | windowRecord printOn: stream ].
	self assert: printed equals: '[MyType] SomeName'.

	windowRecord := DSWindowRecord new name: 'RandomName'.
	printed := String streamContents: [ :stream | windowRecord printOn: stream ].
	self assert: printed equals: '[External Window] RandomName'.

	windowRecord := DSWindowRecord new name: DSWindowOpenedRecord.
	printed := String streamContents: [ :stream | windowRecord printOn: stream ].
	self assert: printed equals: '[External Window] DSWindowOpenedRecord'
]

{ #category : 'tests' }
DSWindowRecordTest >> testPrintTypeOn [

	| windowRecord printed |
	windowRecord := DSWindowRecord new
		                toolInfos: (DSToolInfo new toolClassName: 'StDebugger');
		                type: 'Debugger'.
	printed := String streamContents: [ :stream | windowRecord printTypeOn: stream ].
	self assert: printed equals: 'StDebugger'.

	windowRecord := DSWindowRecord new type: 'Senders'.
	printed := String streamContents: [ :stream | windowRecord printTypeOn: stream ].
	self assert: printed equals: 'Senders'.

	windowRecord := DSWindowRecord new.
	printed := String streamContents: [ :stream | windowRecord printTypeOn: stream ].
	self assert: printed equals: 'External Window'
]

{ #category : 'tests' }
DSWindowRecordTest >> testTotalTime [

	| windowRecord |
	windowRecord := DSWindowRecord new activePeriods: {  }.
	self assert: windowRecord totalTime equals: 0 asSeconds.

	windowRecord := DSWindowRecord new activePeriods: {
			                (DSWindowActivityRecord new
				                 start: (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:00:10' asDateAndTime);
				                 stop: (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:00:46' asDateAndTime)).
			                (DSWindowActivityRecord new
				                 start: (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:04:21' asDateAndTime);
				                 stop: (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:15:38' asDateAndTime)).
			                (DSWindowActivityRecord new
				                 start: (DSMouseEnterWindowRecord new dateTime: '2008-01-22T16:22:07' asDateAndTime);
				                 stop: (DSMouseLeaveWindowRecord new dateTime: '2008-01-22T16:45:58' asDateAndTime)) }.
	self assert: windowRecord totalTime equals: 2144 asSeconds
]

{ #category : 'tests' }
DSWindowRecordTest >> testWindowId [

	| windowRecord |
	windowRecord := DSWindowRecord new events: {
			                (DSWindowOpenedRecord new windowId: 26).
			                (DSDoItRecord new windowId: 57).
			                (DSMouseLeaveWindowRecord new windowId: 98) }.

	self assert: windowRecord windowId equals: 26
]

{ #category : 'tests' }
DSWindowRecordTest >> testWindowNameFor [

	| windowRecord windowOpeningRecord |
	windowRecord := DSWindowRecord new.

	windowOpeningRecord := DSWindowOpenedRecord new windowId: 42.
	self assert: (windowRecord windowNameFor: windowOpeningRecord) equals: 42.

	windowOpeningRecord := DSWindowOpenedRecord new
		                       windowId: 42;
		                       windowName: 'randomWindow'.
	self assert: (windowRecord windowNameFor: windowOpeningRecord) equals: 'randomWindow'.

	windowOpeningRecord := DSMouseEnterWindowRecord new windowId: 36.
	self assert: (windowRecord windowNameFor: windowOpeningRecord) equals: 36
]

{ #category : 'tests' }
DSWindowRecordTest >> testWindowTypeFor [

	| windowRecord windowOpeningRecord |
	windowRecord := DSWindowRecord new.
	windowOpeningRecord := DSWindowOpenedRecord new windowName: 'senders'.

	self assert: (windowRecord windowTypeFor: windowOpeningRecord) equals: 'Senders'
]

Class {
	#name : 'DSWindowRecordTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'tests' }
DSWindowRecordTest >> testAddIdleTime [

	| windowRecord |
	windowRecord := DSWindowRecord new.

	windowRecord addIdleTime: 18 asSeconds.
	self assert: windowRecord idleTime equals: 18 asSeconds.

	windowRecord addIdleTime: 46 asSeconds.
	self assert: windowRecord idleTime equals: 64 asSeconds
]

{ #category : 'tests' }
DSWindowRecordTest >> testIdleTime [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self assert: windowRecord idleTime equals: 0 asSeconds.

	windowRecord := DSWindowRecord new addIdleTime: 36 asSeconds.
	self assert: windowRecord idleTime equals: 36 asSeconds
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
DSWindowRecordTest >> testTrueIdleTime [

	| windowRecord |
	windowRecord := DSWindowRecord new.
	self assert: windowRecord trueIdleTime equals: 0 asSeconds.

	windowRecord := DSWindowRecord new trueIdleTime: 36 asSeconds.
	self assert: windowRecord trueIdleTime equals: 36 asSeconds
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
	self assert: (windowRecord windowNameFor: windowOpeningRecord) equals: 'randomWindow'
]

{ #category : 'tests' }
DSWindowRecordTest >> testWindowTypeFor [

	| windowRecord windowOpeningRecord |
	windowRecord := DSWindowRecord new.
	windowOpeningRecord := DSWindowOpenedRecord new windowName: 'senders'.

	self assert: (windowRecord windowTypeFor: windowOpeningRecord) equals: 'Senders'
]

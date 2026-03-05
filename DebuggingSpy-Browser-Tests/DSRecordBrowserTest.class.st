Class {
	#name : 'DSRecordBrowserTest',
	#superclass : 'TestCase',
	#instVars : [
		'browser'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'helpers' }
DSRecordBrowserTest >> filesPresenter [

	^ browser presenterAt: #fileListPresenter
]

{ #category : 'helpers' }
DSRecordBrowserTest >> generateRecordsFile [
	"Generates a file of random records and returns its file reference."

	| records recordFileRef writeStream |
	records := self getRecordExamples.

	recordFileRef := self temporaryDirectory / ('ds-spy-test-' , UUID new asString).
	recordFileRef ensureCreateFile.
	writeStream := recordFileRef writeStream.

	writeStream nextPut: $[.

	records doWithIndex: [ :record :index |
			writeStream nextPutAll: (STON toString: record).

			index = records size ifFalse: [
					writeStream nextPut: $,.
					writeStream crlf ] ].

	writeStream nextPut: $].

	writeStream close.

	^ recordFileRef
]

{ #category : 'helpers' }
DSRecordBrowserTest >> getRecordExamples [

	^ OrderedCollection new
		  add: (DSBrowseRecord new
				   windowId: 1;
				   dateTime: (DateAndTime fromSeconds: 1);
				   yourself);
		  add: (DSMouseEnterWindowRecord new
				   windowId: 2;
				   dateTime: (DateAndTime fromSeconds: 2);
				   yourself);
		  add: (DSMouseLeaveWindowRecord new
				   windowId: 3;
				   dateTime: (DateAndTime fromSeconds: 3);
				   yourself);
		  add: (DSInspectItRecord new
				   windowId: 4;
				   dateTime: (DateAndTime fromSeconds: 4);
				   yourself);
		  yourself
]

{ #category : 'helpers' }
DSRecordBrowserTest >> recordsFilterPresenter [

	^ browser presenterAt: #recordsFilter
]

{ #category : 'helpers' }
DSRecordBrowserTest >> recordsTablePresenter [

	^ browser presenterAt: #recordsTablePresenter
]

{ #category : 'running' }
DSRecordBrowserTest >> setUp [

	super setUp.
	browser := DSRecordBrowser new
]

{ #category : 'running' }
DSRecordBrowserTest >> tearDown [

	DSRecordBrowser resetBrowser.
	super tearDown
]

{ #category : 'tests' }
DSRecordBrowserTest >> testAddFile [

	| fileRef |
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.
	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.

	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserTest >> testAddFileWhenAlreadyInList [

	| fileRef |
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.
	browser addFile: fileRef.
	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.
	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserTest >> testBrowserEmpty [

	self assertEmpty: browser files.
	self assert: self filesPresenter items size equals: 0.
	self assert: self filesPresenter selectedItem equals: nil.
	self assert: self recordsTablePresenter roots size equals: 0
]

{ #category : 'tests' }
DSRecordBrowserTest >> testClosingBrowser [

	DSRecordBrowser toggleBrowser.
	DSRecordBrowser toggleBrowser.
	self deny: DSRecordBrowser uniqueInstance window isOpen
]

{ #category : 'tests' }
DSRecordBrowserTest >> testCreatingAndOpeningBrowser [

	DSRecordBrowser toggleBrowser.
	self assert: DSRecordBrowser uniqueInstance window isOpen.
	DSRecordBrowser toggleBrowser
]

{ #category : 'tests' }
DSRecordBrowserTest >> testFilteringAClassOfRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.
	self assert: self recordsTablePresenter roots size equals: history records size.

	self recordsFilterPresenter sourceList selectItem: DSBrowseRecord.
	self recordsFilterPresenter addSelected.

	self deny: self recordsTablePresenter roots first class equals: DSBrowseRecord
]

{ #category : 'tests' }
DSRecordBrowserTest >> testFilteringAllRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.

	self recordsFilterPresenter addAll.
	self assert: self recordsTablePresenter roots size equals: 0
]

{ #category : 'tests' }
DSRecordBrowserTest >> testGetHistoryFrom [

	| fileRef |
	fileRef := self generateRecordsFile.
	self assert: (browser getHistoryFrom: fileRef) class equals: DSRecordHistory
]

{ #category : 'tests' }
DSRecordBrowserTest >> testGetRecordColorAssociationsFrom [

	| fileRef history colorAssociations |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.
	colorAssociations := browser getRecordColorAssociationsFrom: history windows.

	self assert: colorAssociations first key class equals: DSBrowseRecord.
	self assert: (colorAssociations at: 2) key class equals: DSMouseEnterWindowRecord.
	self assert: (colorAssociations at: 3) key class equals: DSMouseLeaveWindowRecord.
	self assert: colorAssociations last key class equals: DSInspectItRecord
]

{ #category : 'tests' }
DSRecordBrowserTest >> testRemoveFile [

	| fileRef1 fileRef2 |
	fileRef1 := self generateRecordsFile.
	fileRef2 := self generateRecordsFile.

	browser addFile: fileRef1.
	browser addFile: fileRef2.
	browser removeFile: fileRef1.

	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.
	self assert: self filesPresenter selectedItem equals: fileRef2
]

{ #category : 'tests' }
DSRecordBrowserTest >> testRemoveLastFile [

	| fileRef1 |
	fileRef1 := self generateRecordsFile.

	browser addFile: fileRef1.
	browser removeFile: fileRef1.

	self assert: browser files size equals: 0.
	self assert: self filesPresenter items size equals: 0.
	self assert: self filesPresenter selectedItem equals: nil
]

{ #category : 'tests' }
DSRecordBrowserTest >> testStartRecording [

	self assert: browser timerWindow isNil.
	self deny: DSRecordRegistry autoSerialize.
	self deny: DSSpy recordingSession.

	browser startRecording.
	self assert: DSSpy recordingSession.
	self assert: DSRecordRegistry autoSerialize.
	self deny: browser timerWindow isNil.

	browser stopRecording
]

{ #category : 'tests' }
DSRecordBrowserTest >> testStopRecording [

	| timerWindow |
	browser startRecording.
	timerWindow := browser timerWindow.
	browser stopRecording.

	self deny: (self currentWorld submorphs includes: timerWindow).
	self assert: browser timerWindow isNil
]

{ #category : 'tests' }
DSRecordBrowserTest >> testUpdateRecordsTable [

	| fileRef history presenterMock |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.
	presenterMock := MockObject new on: #selectedItem respond: fileRef.
	browser updateRecordsTable: presenterMock.

	self assert: self recordsTablePresenter roots first key class equals: DSBrowseRecord.
	self assert: (self recordsTablePresenter roots at: 2) key class equals: DSMouseEnterWindowRecord.
	self assert: (self recordsTablePresenter roots at: 3) key class equals: DSMouseLeaveWindowRecord.
	self assert: self recordsTablePresenter roots last key class equals: DSInspectItRecord
]

{ #category : 'tests' }
DSRecordBrowserTest >> testUpdateRecordsTableWhenAddingFile [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.

	self assert: self recordsTablePresenter roots first key class equals: DSBrowseRecord.
	self assert: (self recordsTablePresenter roots at: 2) key class equals: DSMouseEnterWindowRecord.
	self assert: (self recordsTablePresenter roots at: 3) key class equals: DSMouseLeaveWindowRecord.
	self assert: self recordsTablePresenter roots last key class equals: DSInspectItRecord
]

{ #category : 'helpers' }
DSRecordBrowserTest >> timelinePresenter [

	^ browser presenterAt: #graphicTimeline 
]

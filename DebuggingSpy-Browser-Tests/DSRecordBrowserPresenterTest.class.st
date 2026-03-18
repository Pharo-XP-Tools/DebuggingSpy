Class {
	#name : 'DSRecordBrowserPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'browser'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> filesPresenter [

	^ browser presenterAt: #fileListPresenter
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> generateRecordsFile [
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
DSRecordBrowserPresenterTest >> getRecordExamples [

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
DSRecordBrowserPresenterTest >> recordsFilterPresenter [

	^ browser presenterAt: #recordsFilter
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> recordsTablePresenter [

	^ browser presenterAt: #recordsTablePresenter
]

{ #category : 'running' }
DSRecordBrowserPresenterTest >> setUp [

	super setUp.
	browser := DSRecordBrowserPresenter new
]

{ #category : 'running' }
DSRecordBrowserPresenterTest >> tearDown [

	DSRecordBrowserPresenter resetBrowser.
	super tearDown
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testAddFile [

	| fileRef |
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.
	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.

	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testAddFileWhenAlreadyInList [

	| fileRef |
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.
	browser addFile: fileRef.
	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.
	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testAddingMultipleFiles [

	| fileRef |
	browser addFile: self generateRecordsFile.
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.

	self assert: browser files size equals: 2.
	self assert: self filesPresenter items size equals: 2.
	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testBrowserEmpty [

	self assertEmpty: browser files.
	self assert: self filesPresenter items size equals: 0.
	self assert: self filesPresenter selectedItem equals: nil.
	self assert: self recordsTablePresenter roots size equals: 0
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testClosingBrowser [

	DSRecordBrowserPresenter toggleBrowser.
	DSRecordBrowserPresenter toggleBrowser.
	self deny: DSRecordBrowserPresenter uniqueInstance window isOpen
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testCreatingAndOpeningBrowser [

	DSRecordBrowserPresenter toggleBrowser.
	self assert: DSRecordBrowserPresenter uniqueInstance window isOpen.
	DSRecordBrowserPresenter toggleBrowser
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testFilteringAClassOfRecords [

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
DSRecordBrowserPresenterTest >> testFilteringAllRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.

	self recordsFilterPresenter addAll.
	self assert: self recordsTablePresenter roots size equals: 0
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testGetHistoryFrom [

	| fileRef |
	fileRef := self generateRecordsFile.
	self assert: (browser getHistoryFrom: fileRef) class equals: DSRecordHistory
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testGetRecordColorAssociationsFrom [

	| windows colorAssociations |
	windows := { (DSWindowRecord new
		            toolInfos: (DSToolInfo new
				             toolClassName: 'StPlaygroundPresenter';
				             yourself);
		            events: {
				            DSWindowOpenedRecord new.
				            DSDoItRecord new.
				            DSStepThroughRecord new }) } asOrderedCollection.

	colorAssociations := browser getRecordColorAssociationsFrom: windows.

	self assert: colorAssociations first key class equals: DSWindowOpenedRecord.
	self assert: (colorAssociations at: 2) key class equals: DSDoItRecord.
	self assert: colorAssociations last key class equals: DSStepThroughRecord.

	colorAssociations do: [ :association | self assert: association value equals: (Color fromHexString: '#70B77E') ]
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testRemoveFile [

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
DSRecordBrowserPresenterTest >> testRemoveLastFile [

	| fileRef1 |
	fileRef1 := self generateRecordsFile.

	browser addFile: fileRef1.
	browser removeFile: fileRef1.

	self assert: browser files size equals: 0.
	self assert: self filesPresenter items size equals: 0.
	self assert: self filesPresenter selectedItem equals: nil
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testStartRecording [

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
DSRecordBrowserPresenterTest >> testStopRecording [

	| timerWindow |
	browser startRecording.
	timerWindow := browser timerWindow.
	browser stopRecording.

	self deny: (self currentWorld submorphs includes: timerWindow).
	self assert: browser timerWindow isNil
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testUpdateRecordsTable [

	| fileRef presenterMock |
	fileRef := self generateRecordsFile.
	presenterMock := MockObject new on: #selectedItem respond: fileRef.
	browser updateRecordsTable: presenterMock.

	self assert: self recordsTablePresenter roots first key class equals: DSBrowseRecord.
	self assert: (self recordsTablePresenter roots at: 2) key class equals: DSMouseEnterWindowRecord.
	self assert: (self recordsTablePresenter roots at: 3) key class equals: DSMouseLeaveWindowRecord.
	self assert: self recordsTablePresenter roots last key class equals: DSInspectItRecord
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testUpdateRecordsTableWhenAddingFile [

	browser addFile: self generateRecordsFile.

	self assert: self recordsTablePresenter roots first key class equals: DSBrowseRecord.
	self assert: (self recordsTablePresenter roots at: 2) key class equals: DSMouseEnterWindowRecord.
	self assert: (self recordsTablePresenter roots at: 3) key class equals: DSMouseLeaveWindowRecord.
	self assert: self recordsTablePresenter roots last key class equals: DSInspectItRecord
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> timelinePresenter [

	^ browser presenterAt: #graphicTimeline 
]

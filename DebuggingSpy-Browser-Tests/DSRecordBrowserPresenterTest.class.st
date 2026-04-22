Class {
	#name : 'DSRecordBrowserPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'browser'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'asserting' }
DSRecordBrowserPresenterTest >> assertThat: aRecord equals: anotherRecord [
	"Verifies that all slots are equals between two records."

	self assert: aRecord class equals: anotherRecord class.
	aRecord class allSlots do: [ :slot | self assert: (aRecord readSlot: slot) equals: (anotherRecord readSlot: slot) ]
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> filesPresenter [

	^ browser presenterAt: #fileListPresenter
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> generateRecordsFile [
	"Generates a file of records and returns its file reference."

	^ self generateRecordsFileFor: self getRecordExamples
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> generateRecordsFileFor: someRecords [
	"Generates a file of records and returns its file reference."

	^ self writeRecords: someRecords inFile: self temporaryDirectory / ('ds-spy-test-' , UUID new asString)
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> getRecordExamples [

	^ OrderedCollection new
		  add: (DSBrowseRecord new
				   windowId: 1;
				   dateTime: (DateAndTime fromSeconds: 1));
		  add: (DSMouseEnterWindowRecord new
				   windowId: 2;
				   dateTime: (DateAndTime fromSeconds: 2));
		  add: (DSMouseLeaveWindowRecord new
				   windowId: 3;
				   dateTime: (DateAndTime fromSeconds: 3));
		  add: (DSInspectItRecord new
				   windowId: 4;
				   dateTime: (DateAndTime fromSeconds: 4));
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

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> statisticsPresenter [

	^ browser presenterAt: #statisticsPresenter
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

	browser addFile: self temporaryDirectory.

	self assert: browser files size equals: 1.
	self assert: self filesPresenter roots size equals: 1.
	self assert: self filesPresenter selectedItem equals: self temporaryDirectory.

	browser addFile: fileRef. "fileRef is in temporary directory so it should not be added again"
	self assert: browser files size equals: 1.
	self assert: self filesPresenter roots size equals: 1.
	self assert: self filesPresenter selectedItem equals: self temporaryDirectory
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testAddingMultipleFiles [

	| fileRef |
	browser addFile: self generateRecordsFile.
	fileRef := self generateRecordsFile.

	browser addFile: fileRef.

	self assert: browser files size equals: 2.
	self assert: self filesPresenter roots size equals: 2.
	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testBrowserEmpty [

	self assertEmpty: browser files.
	self assert: self filesPresenter roots size equals: 0.
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
DSRecordBrowserPresenterTest >> testColorAssociations [

	| associations |
	associations := {
		                ((Color fromHexString: '#1f48ff') -> 'Browser').
		                ((Color fromHexString: '#772980') -> 'Debug Point Browser').
		                ((Color fromHexString: '#345e54') -> 'Epicea').
		                ((Color fromHexString: '#00e5ff') -> 'Iceberg').
		                ((Color fromHexString: '#ff9100') -> 'Critique Browser').
		                ((Color fromHexString: '#ff2200') -> 'Debugger').
		                ((Color fromHexString: '#fad314') -> 'Inspector').
		                ((Color fromHexString: '#70B77E') -> 'Playground').
		                (Color white -> 'Rewriter').
		                ((Color fromHexString: '#ec45ff') -> 'Debugging Spy').
		                ((Color fromHexString: '#b3b3b3') -> 'Unknown Window') }.

	self assert: associations size equals: DSRecordBrowserPresenter colorAssociations size.
	associations do: [ :asso | self assert: (DSRecordBrowserPresenter colorAssociations includes: asso) ]
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testCreatingAndOpeningBrowser [

	DSRecordBrowserPresenter toggleBrowser.
	self assert: DSRecordBrowserPresenter uniqueInstance window isOpen.
	DSRecordBrowserPresenter toggleBrowser
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testFileAdding [

	| fileRef |
	fileRef := self writeRecords: self getRecordExamples inFile: self temporaryDirectory / 'ds-spy/test'.
	fileRef ensureCreateFile.
	browser addFile: self temporaryDirectory.

	self assert: (browser isFileAdded: self temporaryDirectory).
	self assert: (browser isFileAdded: fileRef).
	self deny: (browser isFileAdded: 'notAddedFile' asFileReference)
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testFilterRecordClass [

	browser filterRecordClass: DSBrowseRecord.
	self deny: ((browser presenterAt: #recordsFilter) sourceList items includes: DSBrowseRecord).
	self assert: ((browser presenterAt: #recordsFilter) targetList items includes: DSBrowseRecord)
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testFilteringAClassOfRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.
	self assert: self recordsTablePresenter roots size equals: history events size.

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
	self assert: (browser getHistoryFrom: fileRef) class equals: DSRecordHistory.
	self assert: (browser getHistoryFrom: nil) isNil
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testGetRecordColorAssociationsFrom [

	| windows colorAssociations |
	windows := { (DSWindowRecord new
		            toolInfo: (DSToolInfo new
				             toolClass: StPlaygroundPresenter;
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
DSRecordBrowserPresenterTest >> testGetRecordsFromFileReference [

	| records fileRef fileRecords |
	records := self getRecordExamples.
	fileRef := self generateRecordsFileFor: records.

	fileRecords := browser getRecordsFromFileReference: fileRef.

	self assertThat: records first equals: fileRecords first.
	self assertThat: records second equals: fileRecords second.
	self assertThat: records third equals: fileRecords third.
	self assertThat: records fourth equals: fileRecords fourth.

	fileRecords := browser getRecordsFromFileReference: self temporaryDirectory.

	self assertThat: records first equals: fileRecords first.
	self assertThat: records second equals: fileRecords second.
	self assertThat: records third equals: fileRecords third.
	self assertThat: records fourth equals: fileRecords fourth
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testGetRecordsFromFolderReference [

	| records otherRecords fileRecords |
	records := self getRecordExamples.
	otherRecords := {
		                (DSPrintItRecord new
			                 windowId: 0;
			                 dateTime: (DateAndTime fromSeconds: 0)).
		                (DSMouseLeaveWindowRecord new
			                 windowId: 7;
			                 dateTime: (DateAndTime fromSeconds: 7)).
		                (DSMouseEnterWindowRecord new
			                 windowId: 5;
			                 dateTime: (DateAndTime fromSeconds: 5)).
		                (DSInspectItRecord new
			                 windowId: 6;
			                 dateTime: (DateAndTime fromSeconds: 6)) }.

	self generateRecordsFileFor: records.
	self writeRecords: otherRecords inFile: self temporaryDirectory / 'otherRecords'.

	fileRecords := browser getRecordsFromFileReference: self temporaryDirectory.
	self assert: fileRecords size equals: 8.

	self assertThat: fileRecords first equals: otherRecords first.
	self assertThat: fileRecords second equals: records first.
	self assertThat: fileRecords third equals: records second.
	self assertThat: fileRecords fourth equals: records third.
	self assertThat: fileRecords fifth equals: records fourth.
	self assertThat: fileRecords sixth equals: otherRecords third.
	self assertThat: fileRecords seventh equals: otherRecords fourth.
	self assertThat: fileRecords eighth equals: otherRecords second
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testGetWindowFromRecord [

	| record fileRef window |
	fileRef := self generateRecordsFile.
	record := (DSSpy materialize: fileRef) first.

	self filesPresenter items: { fileRef }.
	self filesPresenter selectItem: fileRef.

	window := browser getWindowFromRecord: record.

	self assert: window events first uuid equals: record uuid.
	self assert: window name equals: record windowId
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testIsFileAdded [

	browser files: { 'aFolder' asFileReference } asOrderedCollection.
	self assert: (browser isFileAdded: 'aFolder' asFileReference).
	self assert: (browser isFileAdded: 'aFolder/testFile' asFileReference).
	self deny: (browser isFileAdded: 'notAddedFile' asFileReference)
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
	self assert: self filesPresenter roots size equals: 1.
	self assert: self filesPresenter selectedItem equals: fileRef2
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testRemoveLastFile [

	| fileRef1 |
	fileRef1 := self generateRecordsFile.

	browser addFile: fileRef1.
	browser removeFile: fileRef1.

	self assert: browser files size equals: 0.
	self assert: self filesPresenter roots size equals: 0.
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
DSRecordBrowserPresenterTest >> testUpdateLastRecord [

	| record timerWindow |
	record := DSDoItRecord new.
	timerWindow := DSTimerWindow new.

	self assert: browser timerWindow isNil.
	self assert: (browser updateLastRecord: record) equals: browser.

	browser timerWindow: timerWindow.
	browser updateLastRecord: record.

	self assert: timerWindow lastEventMorph contents equals: record eventName
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testUpdateRecordsTable [

	| fileRef |
	fileRef := self generateRecordsFile.
	browser selectedHistory: (browser getHistoryFrom: fileRef).
	browser updateRecordsTable.

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

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testUpdateStatisticsPresenter [

	| children |
	self assert: browser updateStatisticsPresenter equals: browser.

	browser selectedHistory: (browser getHistoryFrom: self generateRecordsFile).
	browser updateStatisticsPresenter.

	children := self statisticsPresenter children.
	self assert: children size equals: 5.

	self assert: children keys first label equals: 'Number of events: 4'.
	self assert: children keys second label equals: 'Number of windows: 4'.
	self assert: children keys third label equals: 'Time taken: 00:00:03'.
	self assert: children keys fourth label equals: 'Idle time: 00:00:00'.
	self assert: children keys last label equals: 'Absolute time taken: 00:00:03'
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testUpdateWindowsPresenter [

	| records fileRef windows |
	records := self getRecordExamples.
	fileRef := self generateRecordsFileFor: records.
	browser selectedHistory: (browser getHistoryFrom: fileRef).
	browser updateWindowsPresenter.

	windows := self windowsPresenter roots.
	self assert: windows size equals: 4.
	self assert: (windows allSatisfy: [ :window | window class = DSWindowRecord ])
]

{ #category : 'tests' }
DSRecordBrowserPresenterTest >> testWindowColorFrom [

	| record |
	record := DSWindowRecord new toolInfo: (DSToolInfo new toolClass: StDebugger).
	self assert: (DSRecordBrowserPresenter windowColorFrom: record) equals: (Color fromHexString: '#ff2200').
	self assert: (DSRecordBrowserPresenter windowColorFrom: nil) equals: (Color fromHexString: '#b3b3b3')
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> timelinePresenter [

	^ browser presenterAt: #graphicTimeline 
]

{ #category : 'helpers' }
DSRecordBrowserPresenterTest >> windowsPresenter [

	^ browser presenterAt: #windowsPresenter
]

{ #category : 'writing' }
DSRecordBrowserPresenterTest >> writeRecords: someRecords inFile: aFileReference [
	"Write the specified records in the specified file in STON format."

	| writeStream |
	aFileReference ensureCreateFile.
	writeStream := aFileReference writeStream.

	writeStream nextPut: $[.

	someRecords doWithIndex: [ :record :index |
			writeStream nextPutAll: (STON toString: record).

			index = someRecords size ifFalse: [
					writeStream nextPut: $,.
					writeStream crlf ] ].

	writeStream nextPut: $].
	writeStream close.
	^ aFileReference
]

Class {
	#name : 'DSRecordBrowserTest',
	#superclass : 'TestCase',
	#instVars : [
		'browser',
		'logger'
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

	| recordFileRef writeStream randomNbOfRecords |
	randomNbOfRecords := Random new nextInteger: 10.

	recordFileRef := self temporaryDirectory / ('ds-spy-test-' , UUID new asString).
	recordFileRef ensureCreateFile.
	writeStream := recordFileRef writeStream.

	writeStream nextPut: $[.

	1 to: randomNbOfRecords do: [ :index |
			writeStream nextPutAll: (STON toString: (self getRecordForIndex: index)).

			index = randomNbOfRecords ifFalse: [
					writeStream nextPut: $,.
					writeStream crlf ] ].

	writeStream nextPut: $].

	writeStream close.

	^ recordFileRef
]

{ #category : 'helpers' }
DSRecordBrowserTest >> getRecordForIndex: aNumber [
	"Generates a record with specified number as dateTime (in seconds) and as windowId"

	^ self recordClass new
		  dateTime: (DateAndTime fromSeconds: aNumber);
		  windowId: aNumber;
		  yourself
]

{ #category : 'helpers' }
DSRecordBrowserTest >> recordClass [

	^ DSMouseEnterWindowRecord
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

	DSRecordBrowser uniqueInstance window isOpen ifTrue: [ DSRecordBrowser uniqueInstance window close ].
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
	
]

{ #category : 'tests' }
DSRecordBrowserTest >> testClosingBrowser [

	DSRecordBrowser toggleBrowser.
	DSRecordBrowser toggleBrowser.
	self deny: DSRecordBrowser uniqueInstance window isOpen
]

{ #category : 'tests' }
DSRecordBrowserTest >> testCreatingAndOpeningBrowser [

	self deny: DSRecordBrowser uniqueInstance window isOpen.
	DSRecordBrowser toggleBrowser.

	self assert: DSRecordBrowser uniqueInstance window isOpen
]

{ #category : 'tests' }
DSRecordBrowserTest >> testFilteringAClassOfRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.
	self assert: self recordsTablePresenter roots size equals: history records size.

	self recordsFilterPresenter sourceList selectItem: self recordClass.
	self recordsFilterPresenter addSelected.
	
	self assert: self recordsTablePresenter roots size equals: 0 "Since there is only one type of records in the generated file"
]

{ #category : 'tests' }
DSRecordBrowserTest >> testFilteringAllRecords [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.
	self assert: self recordsTablePresenter roots size equals: history records size.

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

	history windows do: [ :window |
			window events do: [ :record |
					self assert: (colorAssociations anySatisfy: [ :association |
							 association key = record and: association value = (browser getWindowColorFrom: window) ]) ] ]
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

	self assert: browser recorderWindow isNil.
	self deny: DSRecordRegistry autoSerialize.
	self deny: DSSpy recordingSession.

	browser startRecording.
	self assert: DSSpy recordingSession.
	self assert: DSRecordRegistry autoSerialize.
	self deny: browser recorderWindow isNil.

	browser stopRecording
]

{ #category : 'tests' }
DSRecordBrowserTest >> testUpdateRecordsTable [

	| fileRef history presenterMock |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.
	presenterMock := MockObject new on: #selectedItem respond: fileRef.
	browser updateRecordsTable: presenterMock.

	self recordsTablePresenter roots do: [ :association |
		self assert: (history records anySatisfy: [ :record | record uuid = association key uuid ]) ]
]

{ #category : 'tests' }
DSRecordBrowserTest >> testUpdateRecordsTableWhenAddingFile [

	| fileRef history |
	fileRef := self generateRecordsFile.
	history := browser getHistoryFrom: fileRef.

	browser addFile: fileRef.

	self assert: self recordsTablePresenter roots size equals: history records size
]

{ #category : 'helpers' }
DSRecordBrowserTest >> timelinePresenter [

	^ browser presenterAt: #graphicTimeline 
]

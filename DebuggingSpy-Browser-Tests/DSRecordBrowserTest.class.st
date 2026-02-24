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

	^ browser presenterAt: #addedFilesPresenter
]

{ #category : 'helpers' }
DSRecordBrowserTest >> generateRecordFile: aNumberOfRecords [

	| recordFileRef records |
	DSSpy recordingSession ifFalse: [ browser startRecording ].

	recordFileRef := self updateLoggerFileName.
	records := OrderedCollection new.

	1 to: aNumberOfRecords do: [ :i |
			records add: (DSMouseEnterWindowRecord new
					 windowId: 'test' , i asString;
					 dateTime: (DateAndTime fromSeconds: 50 * i)) ].

	records do: [ :record | DSRecordRegistry current addRecord: record ].
	^ recordFileRef
]

{ #category : 'helpers' }
DSRecordBrowserTest >> selectedRecordsPresenter [

	^ browser presenterAt: #selectedRecordsPresenter
]

{ #category : 'running' }
DSRecordBrowserTest >> setUp [

	super setUp.

	DSSpy testingSession: true.

	logger := DSSpy logger loggingDirectory: self temporaryDirectory.
	self updateLoggerFileName.

	browser := DSRecordBrowser new
]

{ #category : 'running' }
DSRecordBrowserTest >> tearDown [

	DSRecordRegistry current reset.
	DSSpy recordingSession ifTrue: [ browser stopRecording ].

	super tearDown
]

{ #category : 'tests' }
DSRecordBrowserTest >> testAddFile [

	| fileRef |
	fileRef := self generateRecordFile: 42.

	browser addFile: fileRef.
	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.

	self assert: self filesPresenter selectedItem equals: fileRef
]

{ #category : 'tests' }
DSRecordBrowserTest >> testAddFileWhenAlreadyInList [

	| fileRef |
	fileRef := self generateRecordFile: 42.

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
DSRecordBrowserTest >> testGetColoredRecordsOf [

	| fileRef history coloredRecords |
	fileRef := self generateRecordFile: 10.
	history := DSRecordBrowser getHistoryOf: fileRef.
	coloredRecords := DSRecordBrowser getColoredRecordsOf: history windows.
	coloredRecords do: [ :c |
			self
				assert: c color
				equals: (DSRecordBrowser getWindowColorFor: (history windows select: [ :i | i events includes: c record ]) first) ]
]

{ #category : 'tests' }
DSRecordBrowserTest >> testGetHistoryOf [

	| fileRef |
	fileRef := self generateRecordFile: 5.
	self assert: (DSRecordBrowser getHistoryOf: fileRef) records size equals: 5
]

{ #category : 'tests' }
DSRecordBrowserTest >> testRemoveFile [

	| fileRef1 fileRef2 |
	fileRef1 := self generateRecordFile: 42.
	fileRef2 := self generateRecordFile: 42.

	browser addFile: fileRef1.
	browser addFile: fileRef2.
	browser removeFile: fileRef1.

	self assert: browser files size equals: 1.
	self assert: self filesPresenter items size equals: 1.
	self assert: self filesPresenter selectedItem equals: fileRef2
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
]

{ #category : 'helpers' }
DSRecordBrowserTest >> timelinePresenter [

	^ browser presenterAt: #timeline
]

{ #category : 'helpers' }
DSRecordBrowserTest >> toolbarPresenter [

	^ browser presenterAt: #toolbar
]

{ #category : 'helpers' }
DSRecordBrowserTest >> updateLoggerFileName [
	"Changes the logging file name, needs to be called everytime a new file is created for the logger to be updated for future logs.
Using a UUID ensures that multiple files created at the same date and time dont have the same file name."

	| fr |
	logger loggingFileName: UUID new asString.
	fr := logger ensureCreateLoggingFileReference.
	logger loggingFileReference: fr.
	^ fr
]

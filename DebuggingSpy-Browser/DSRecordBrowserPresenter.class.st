"
Debugging Spy main interface thats includes :
- an interface that could be opened with a button on the topside bar 
- a button that adds files to the list displayed on the interface
- a button to start the instrumentation and another to stop it
- an interface that shows the content of a selected file
"
Class {
	#name : 'DSRecordBrowserPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'files',
		'selectedRecords',
		'startRecordButton',
		'stopRecordButton',
		'addRecordButton',
		'toolbar',
		'addedFilesPresenter',
		'selectedRecordsPresenter',
		'recorderWindow'
	],
	#classInstVars : [
		'presenterWindow'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'world menu' }
DSRecordBrowserPresenter class >> menuCommandOn: aBuilder [
	"Adds the DSSpy button on topside bar, the order is 100 just to make sure the DSSpy button is at the end"

	<worldMenu>
	(aBuilder item: #DSSpy)
		order: 100;
		help: 'Open the Debugging Spy browser.';
		action: [ self toggleBrowser ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> presenterWindow [

	^ presenterWindow
]

{ #category : 'initialization' }
DSRecordBrowserPresenter class >> resetBrowser [

	<script>
	presenterWindow := nil
]

{ #category : 'open/close' }
DSRecordBrowserPresenter class >> toggleBrowser [

	| presenter |
	presenterWindow ifNotNil: [
			^ presenterWindow isOpen
				  ifTrue: [ presenterWindow close ]
				  ifFalse: [ presenterWindow open ] ].

	presenter := self new.
	presenter open.
	presenterWindow := presenter window
]

{ #category : 'adding' }
DSRecordBrowserPresenter >> addFile: aFileReference [

	files add: aFileReference.
	addedFilesPresenter items: files.
	self updateContentViewer: aFileReference
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> addRecordButton [

	^ addRecordButton ifNil: [
			  addRecordButton := SpToolbarButtonPresenter new
				                     label: 'Add';
				                     icon: (self iconNamed: #smallAdd);
				                     help: 'Add a new record.';
				                     action: [ self openAddFileDialog ];
				                     yourself ]
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> connectPresenters [

	selectedRecords ifNotNil: [
			selectedRecordsPresenter
				roots: selectedRecords records;
				children: [ :item | OrderedCollection new ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: toolbar expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: addedFilesPresenter;
				   add: selectedRecordsPresenter;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> getHistoryOf: aFileReference [

	^ DSRecordHistory on: (DSSpy materialize: aFileReference)
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> initializePresenters [

	toolbar := self newToolbar
		           addItem: self addRecordButton;
		           addItem: self startRecordButton;
		           addItem: self stopRecordButton.

	addedFilesPresenter := self newList
		                       items: self files;
		                       display: [ :file | file basenameWithoutExtension ];
		                       whenSelectionChangedDo: [ :file | file ifNotNil: [ self updateContentViewer: file selectedItem ] ];
		                       actions: self listAddedFilesActions;
		                       yourself.

	selectedRecordsPresenter := self newTreeTable
		                            addColumn: (SpStringTableColumn title: 'Event type' evaluated: [ :item | item eventName asString ]);
		                            addColumn: (SpStringTableColumn title: 'Time' evaluated: [ :item | item dateTime asTime print24 ]);
		                            beResizable;
		                            yourself
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> listAddedFilesActions [

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  description: 'Inspect the raw records';
					  shortcutKey: $i meta;
					  action: [ (DSSpy materialize: addedFilesPresenter selectedItem) inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect history';
					  description: 'Inspect the record history';
					  shortcutKey: $h meta;
					  action: [ (self getHistoryOf: addedFilesPresenter selectedItem) inspect ] ];
		  yourself
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> openAddFileDialog [

	| fileNames |
	fileNames := StOpenFilePresenter new
		             beMultipleSelection;
		             defaultFolder: DSSpy logger loggingDirectory;
		             openModal.
	fileNames ifNotNil: [ fileNames do: [ :file | self addFile: file asFileReference ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> startRecordButton [

	^ startRecordButton ifNil: [
			  startRecordButton := SpToolbarButtonPresenter new
				                       label: 'Start';
				                       icon: (self iconNamed: #glamorousGo);
				                       help: 'Start recording events.';
				                       action: [ self startRecording ];
				                       enabled: DSSpy recordingSession not;
				                       yourself ]
]

{ #category : 'recording' }
DSRecordBrowserPresenter >> startRecording [
	"Starts recording events and instianciates a new RecorderWindow that displays a timer and shows that Debugging Spy is recordering."

	DSSpyInstrumenter instrumentSystem.
	startRecordButton enabled: false.
	stopRecordButton enabled: true.
	recorderWindow := DSRecorderWindow new.
	recorderWindow
		openInWorld;
		startTimer
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> stopRecordButton [

	^ stopRecordButton ifNil: [
			  stopRecordButton := SpToolbarButtonPresenter new
				                      label: 'Stop';
				                      icon: (self iconNamed: #stop);
				                      help: 'Stop recording events.';
				                      action: [ self stopRecording ];
				                      enabled: DSSpy recordingSession;
				                      yourself ]
]

{ #category : 'recording' }
DSRecordBrowserPresenter >> stopRecording [
	"Stops the recording session and closes the RecorderWindow."

	DSSpyInstrumenter stopInstrumentation.
	startRecordButton enabled: true.
	stopRecordButton enabled: false.
	recorderWindow stopTimer.
	self currentWorld removeMorph: recorderWindow
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateContentViewer: aFileReference [

	aFileReference ifNotNil: [
			selectedRecords := self getHistoryOf: aFileReference.
			self connectPresenters ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowIcon [

	^ self iconNamed: #browse
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowTitle [

	^ 'Debugging record browser'
]

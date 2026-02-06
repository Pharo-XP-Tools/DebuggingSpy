"
Debugging Spy interface.
"
Class {
	#name : 'RecordBrowserPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'files',
		'toolbar',
		'selectedRecordsPresenter',
		'selectedRecords',
		'addedFilesPresenter',
		'startRecordButton',
		'stopRecordButton',
		'addRecordButton'
	],
	#classInstVars : [
		'browser'
	],
	#category : 'RecordBrowser',
	#package : 'RecordBrowser'
}

{ #category : 'accessing' }
RecordBrowserPresenter class >> browser [

	^ browser
]

{ #category : 'world menu' }
RecordBrowserPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #DSSpy)
		order: 100;
		help: 'Open the Debugging Spy browser.';
		action: [ self new open ]
]

{ #category : 'adding' }
RecordBrowserPresenter >> addFile: aFileReference [

	files add: aFileReference.
	addedFilesPresenter items: files.
	self updateContentViewer: aFileReference
]

{ #category : 'layout' }
RecordBrowserPresenter >> addRecordButton [

	^ addRecordButton ifNil: [
			  addRecordButton := SpToolbarButtonPresenter new
				                     label: 'Add';
				                     icon: (self iconNamed: #smallAdd);
				                     help: 'Add a new record.';
				                     action: [ self openAddFileDialog ];
				                     yourself ]
]

{ #category : 'initialization' }
RecordBrowserPresenter >> connectPresenters [

	selectedRecords ifNotNil: [
			selectedRecordsPresenter
				roots: selectedRecords records;
				children: [ :item | OrderedCollection new ] ]
]

{ #category : 'layout' }
RecordBrowserPresenter >> defaultLayout [

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
RecordBrowserPresenter >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'initialization' }
RecordBrowserPresenter >> initializePresenters [

	toolbar := self newToolbar
		           addItem: self addRecordButton;
		           addItem: self startRecordButton;
		           addItem: self stopRecordButton.

	addedFilesPresenter := self newList
		                       items: self files;
		                       display: [ :file | file basenameWithoutExtension ];
		                       whenSelectionChangedDo: [ :file | file ifNotNil: [ self updateContentViewer: file selectedItem ] ];
		                       yourself.

	selectedRecordsPresenter := self newTreeTable
		                            addColumn: (SpStringTableColumn title: 'Event type' evaluated: [ :item | item eventName asString ]);
		                            addColumn: (SpStringTableColumn title: 'Time' evaluated: [ :item | item dateTime asTime print24 ]);
		                            beResizable;
		                            yourself
]

{ #category : 'operations' }
RecordBrowserPresenter >> openAddFileDialog [

	| fileNames |
	fileNames := StOpenFilePresenter new
		             defaultFolder: DSSpy logger loggingDirectory;
		             openModal.
	fileNames ifNotNil: [ fileNames do: [ :file | self addFile: file asFileReference ] ]
]

{ #category : 'layout' }
RecordBrowserPresenter >> startRecordButton [

	^ startRecordButton ifNil: [
			  startRecordButton := SpToolbarButtonPresenter new
				                       label: 'Start';
				                       icon: (self iconNamed: #glamorousGo);
				                       help: 'Start recording events.';
				                       action: [
						                       DSSpyInstrumenter instrumentSystem.
						                       startRecordButton enabled: false.
						                       stopRecordButton enabled: true ];
				                       enabled: DSSpy recordingSession not;
				                       yourself ]
]

{ #category : 'layout' }
RecordBrowserPresenter >> stopRecordButton [

	^ stopRecordButton ifNil: [
			  stopRecordButton := SpToolbarButtonPresenter new
				                      label: 'Stop';
				                      icon: (self iconNamed: #stop);
				                      help: 'Stop recording events.';
				                      action: [
						                      DSSpyInstrumenter stopInstrumentation.
						                      startRecordButton enabled: true.
						                      stopRecordButton enabled: false ];
				                      enabled: DSSpy recordingSession;
				                      yourself ]
]

{ #category : 'operations' }
RecordBrowserPresenter >> updateContentViewer: aFileReference [

	| raw history |
	aFileReference ifNotNil: [
			raw := DSSpy materialize: aFileReference.
			history := DSRecordHistory on: raw.
			selectedRecords := history.
			self connectPresenters ]
]

{ #category : 'accessing' }
RecordBrowserPresenter >> windowTitle [

	^ 'Debugging record browser'
]

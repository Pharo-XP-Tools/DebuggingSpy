"
Debugging Spy main interface thats includes :
- an interface that could be opened with a button on the topside bar 
- a button that adds files to the list displayed on the interface
- a button to start the instrumentation and another to stop it
- an interface that shows the content of a selected file
"
Class {
	#name : 'DSRecordBrowser',
	#superclass : 'SpPresenter',
	#instVars : [
		'files',
		'selectedRecords',
		'toolbar',
		'addedFilesPresenter',
		'selectedRecordsPresenter',
		'recorderWindow',
		'timeline',
		'recordsFilter'
	],
	#classInstVars : [
		'presenter'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'accessing' }
DSRecordBrowser class >> browser [

	^ presenter ifNil: [ presenter := self new ]
]

{ #category : 'color' }
DSRecordBrowser class >> getColoredRecordsOf: aWindowRecordCollection [

	| coloredRecords |
	coloredRecords := OrderedCollection new.
	aWindowRecordCollection do: [ :windowRecord |
			coloredRecords addAll:
				(windowRecord events collect: [ :record | DSColoredRecord for: record withColor: (self getWindowColorFor: windowRecord) ]) ].
	coloredRecords sort: [ :i :j | i record dateTime < j record dateTime ].
	^ coloredRecords
]

{ #category : 'operations' }
DSRecordBrowser class >> getHistoryOf: aFileReference [

	^ DSRecordHistory on: (DSSpy materialize: aFileReference)
]

{ #category : 'operations' }
DSRecordBrowser class >> getTimelinePointsFrom: aHistory [

	^ aHistory windows collectWithIndex: [ :w :index |
			  RSTimeLinePlot new
				  entries: {
						  w events first dateTime asNanoSeconds.
						  w events last dateTime asNanoSeconds }
				  at: index;
				  color: (self getWindowColorFor: w) ]
]

{ #category : 'color' }
DSRecordBrowser class >> getWindowColorFor: aWindowRecord [

	aWindowRecord isBrowser ifTrue: [ ^ Color fromHexString: '#2A2AB7' ].
	aWindowRecord isInspector ifTrue: [ ^ Color fromHexString: '#FFC300' ].
	aWindowRecord isDebugger ifTrue: [ ^ Color fromHexString: '#C41E3D' ].
	
	aWindowRecord isPlayground ifTrue: [ ^ Color fromHexString: '#70B77E' ].
	aWindowRecord isBreakpointBrowser ifTrue: [ ^ Color fromHexString: '#7C238C' ].
	aWindowRecord isCritiqueBrowser ifTrue: [ ^ Color fromHexString: '#A45C15' ].
	aWindowRecord isEpicea ifTrue: [ ^ Color fromHexString: '#345e54' ].
	aWindowRecord isIceberg ifTrue: [ ^ Color fromHexString: '#2B5BA9' ].
	aWindowRecord isRewriter ifTrue: [ ^ Color fromHexString: '#292929' ].

	^ Color gray
]

{ #category : 'world menu' }
DSRecordBrowser class >> menuCommandOn: aBuilder [
	"Adds the DSSpy button on topside bar, the order is 100 just to make sure the DSSpy button is at the end"

	<worldMenu>
	(aBuilder item: #DSSpy)
		order: 100;
		help: 'Open the Debugging Spy browser.';
		action: [ self toggleBrowser ]
]

{ #category : 'initialization' }
DSRecordBrowser class >> resetBrowser [

	<script>
	presenter := nil
]

{ #category : 'open/close' }
DSRecordBrowser class >> toggleBrowser [

	presenter ifNotNil: [
			^ presenter window isOpen
				  ifTrue: [ presenter window close ]
				  ifFalse: [ presenter window open ] ].

	self browser open
]

{ #category : 'adding' }
DSRecordBrowser >> addFile: aFileReference [
	"Adds a file in the presenter and set is as selected, which updates the records displayed."

	(files includes: aFileReference)
		ifTrue: [ ^ self inform: 'File already added in the browser !' ]
		ifFalse: [
				files add: aFileReference.
				addedFilesPresenter items: files.
				addedFilesPresenter selectItem: aFileReference ]
]

{ #category : 'layout' }
DSRecordBrowser >> addRecordButton [

	^ SpToolbarButtonPresenter new
		  label: 'Add';
		  icon: (self iconNamed: #smallAdd);
		  help: 'Add a new record.';
		  action: [ self openAddFileDialog ];
		  yourself
]

{ #category : 'initialization' }
DSRecordBrowser >> connectPresenters [
	"Updates the records and the timeline whenever the selected file is changed."

	addedFilesPresenter whenSelectionChangedDo: [ :presenter |
			presenter selectedItem ifNotNil: [
					self updateSelectedRecords: presenter.
					self updateTimelineChart ] ].

	recordsFilter whenChangedDo: [
			addedFilesPresenter selectedItem ifNotNil: [
					self updateSelectedRecords: addedFilesPresenter.
					self updateTimelineChart ] ]
]

{ #category : 'layout' }
DSRecordBrowser >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: toolbar expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: addedFilesPresenter;
				   add: (SpBoxLayout newTopToBottom
						    add: (SpTabLayout new
								     add: selectedRecordsPresenter label: 'Records';
								     add: timeline label: 'Timeline';
								     yourself);
						    yourself);
				   yourself)
]

{ #category : 'accessing' }
DSRecordBrowser >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'layout' }
DSRecordBrowser >> filterRecordsButton [

	^ SpToolbarButtonPresenter new
		  label: 'Filter';
		  icon: (self iconNamed: #diff);
		  help: 'Filter the records.';
		  action: [ self recordsFilter open ];
		  yourself
]

{ #category : 'initialization' }
DSRecordBrowser >> initializePresenters [

	toolbar := self newToolbar
		           addItem: self addRecordButton;
		           addItem: self startRecordButton;
		           addItem: self stopRecordButton;
		           addItem: self filterRecordsButton.

	addedFilesPresenter := self newList
		                       items: self files;
		                       display: [ :file | file basenameWithoutExtension ];
		                       actions: self listAddedFilesActions;
		                       yourself.

	selectedRecordsPresenter := self recordsTable.
	timeline := self newRoassal.
	recordsFilter := self recordsFilter
]

{ #category : 'operations' }
DSRecordBrowser >> listAddedFilesActions [

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
					  action: [ (self class getHistoryOf: addedFilesPresenter selectedItem) inspect ] ];
		  yourself
]

{ #category : 'operations' }
DSRecordBrowser >> listRecordActions [

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  description: 'Inspect the raw records';
					  shortcutKey: $i meta;
					  action: [ selectedRecordsPresenter selectedItem record inspect ] ];
		  yourself
]

{ #category : 'operations' }
DSRecordBrowser >> openAddFileDialog [
	"Opens a dialog where the user can select a file to be addded into the presenter."

	| newFiles |
	newFiles := StOpenFilePresenter new
		            beMultipleSelection;
		            defaultFolder: DSSpy logger loggingDirectory;
		            openModal.
	newFiles ifNotNil: [ newFiles do: [ :file | self addFile: file asFileReference ] ]
]

{ #category : 'accessing' }
DSRecordBrowser >> recorderWindow [

	^ recorderWindow
]

{ #category : 'accessing' }
DSRecordBrowser >> recordsFilter [

	^ recordsFilter ifNil: [ recordsFilter := SpChooserPresenter new sourceItems: DSAbstractEventRecord getRecordClasses ]
]

{ #category : 'layout' }
DSRecordBrowser >> recordsTable [

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   title: 'Event';
				   displayBackgroundColor: [ :coloredRecord | coloredRecord color ];
				   evaluated: [ :coloredRecord | coloredRecord record eventName asString ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Event type';
				   displayBackgroundColor: [ :coloredRecord | coloredRecord color ];
				   evaluated: [ :coloredRecord | coloredRecord record class asString ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Time';
				   displayBackgroundColor: [ :coloredRecord | coloredRecord color ];
				   evaluated: [ :coloredRecord | coloredRecord record dateTime asTime print24 ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  beResizable;
		  actions: self listRecordActions;
		  yourself
]

{ #category : 'initialization' }
DSRecordBrowser >> resetBrowser [

	<script: 'self resetBrowser'>
]

{ #category : 'layout' }
DSRecordBrowser >> startRecordButton [

	^ SpToolbarButtonPresenter new
		  label: 'Start';
		  icon: (self iconNamed: #glamorousGo);
		  help: 'Start recording events.';
		  action: [ self startRecording ];
		  enabled: DSSpy recordingSession not;
		  yourself
]

{ #category : 'recording' }
DSRecordBrowser >> startRecording [
	"Starts recording events and instianciates a new RecorderWindow that displays a timer and shows that Debugging Spy is recordering."

	DSSpyInstrumenter instrumentSystem.
	(toolbar leftItems at: 2) enabled: false. "Disable the start recording button."
	(toolbar leftItems at: 3) enabled: true. "Enable the stop recording button."
	recorderWindow := DSRecorderWindow new.
	recorderWindow
		openInWorld;
		startTimer
]

{ #category : 'layout' }
DSRecordBrowser >> stopRecordButton [

	^ SpToolbarButtonPresenter new
		  label: 'Stop';
		  icon: (self iconNamed: #stop);
		  help: 'Stop recording events.';
		  action: [ self stopRecording ];
		  enabled: DSSpy recordingSession;
		  yourself
]

{ #category : 'recording' }
DSRecordBrowser >> stopRecording [
	"Stops the recording session and closes the RecorderWindow."

	DSSpyInstrumenter stopInstrumentation.
	(toolbar leftItems at: 2) enabled: true. "Enable the start recording button."
	(toolbar leftItems at: 3) enabled: false. "Disable the stop recording button."
	recorderWindow ifNotNil: [
			recorderWindow stopTimer.
			self currentWorld removeMorph: recorderWindow ]
]

{ #category : 'layout' }
DSRecordBrowser >> timelineChart [

	| history names chart data |
	addedFilesPresenter selectedItem ifNil: [ ^ nil ].

	history := self class getHistoryOf: addedFilesPresenter selectedItem.
	names := history windows collect: [ :i | i getWindowType ].

	data := self class getTimelinePointsFrom: history.
	data size < 2 ifTrue: [^ nil].
	
	chart := RSCompositeChart new.
	chart addAll: data.

	chart verticalTick fromNames: names.

	chart horizontalTick
		useNiceLabel;
		numberOfTicks: history windows size // 2;
		useDiagonalLabel;
		labelConversion: [ :v | (DateAndTime fromSeconds: v // 1000000000) asTime ].

	chart build.
	^ chart
]

{ #category : 'operations' }
DSRecordBrowser >> updateSelectedRecords: aPresenter [
	"Updates the selected records and processes it to be used with their respective colors."

	| records |
	records := self class getColoredRecordsOf: (self class getHistoryOf: aPresenter selectedItem) windows.
	records := records reject: [ :coloredRecord | self recordsFilter chosenItems includes: coloredRecord record class ].
	selectedRecords := records.
	selectedRecordsPresenter
		roots: selectedRecords;
		children: [ :item | OrderedCollection new ]
]

{ #category : 'operations' }
DSRecordBrowser >> updateTimelineChart [

	| chart |
	chart := self timelineChart.
	chart ifNotNil: [ timeline script: [ :canvas | chart renderIn: canvas ] ].
	timeline refresh
]

{ #category : 'accessing' }
DSRecordBrowser >> windowIcon [

	^ self iconNamed: #smallObjects 
]

{ #category : 'accessing' }
DSRecordBrowser >> windowTitle [

	^ 'Debugging record browser'
]

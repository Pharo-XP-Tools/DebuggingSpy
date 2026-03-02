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
		'recordsTablePresenter',
		'timerWindow',
		'graphicTimeline',
		'recordsFilter',
		'toolbarPresenter',
		'fileListPresenter',
		'startRecordButtonPresenter',
		'stopRecordButtonPresenter'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'world menu' }
DSRecordBrowser class >> menuCommandOn: aBuilder [
	"Adds the DSSpy button on topside bar."

	<worldMenu>
	(aBuilder item: #DSSpy)
		order: 100;
		help: 'Open the Debugging Spy browser.';
		action: [ self toggleBrowser ]
]

{ #category : 'initialization' }
DSRecordBrowser class >> resetBrowser [
	"Removes the actual browser then another one will be created the next time it needs to be opened."

	<script>
	uniqueInstance := nil
]

{ #category : 'open/close' }
DSRecordBrowser class >> toggleBrowser [
	"Opens the browser or closes it depending on its state. If it needs to be created, then creates and opens it. See uniqueInstance method."

	uniqueInstance ifNotNil: [
			^ uniqueInstance window isOpen
				  ifTrue: [ uniqueInstance window close ]
				  ifFalse: [ uniqueInstance window open ] ].
	self uniqueInstance open
]

{ #category : 'accessing' }
DSRecordBrowser class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'files' }
DSRecordBrowser >> addFile: aFileReference [
	"Adds a file in the presenter and set is as selected, which updates the records displayed."

	(files includes: aFileReference)
		ifTrue: [ ^ self inform: 'File already added !' ]
		ifFalse: [
				files add: aFileReference.
				fileListPresenter items: files.
				fileListPresenter selectItem: aFileReference ]
]

{ #category : 'layout' }
DSRecordBrowser >> addRecordButton [
	"Layout button that opens a file selecting window."

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

	fileListPresenter whenSelectionChangedDo: [ :presenter |
			fileListPresenter selectedItem ifNotNil: [
					self updateRecordsTable: presenter.
					self updateTimelineChart ] ].

	recordsFilter whenChangedDo: [ fileListPresenter selectedItem ifNotNil: [ self updateRecordsTable: fileListPresenter ] ]
]

{ #category : 'layout' }
DSRecordBrowser >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: toolbarPresenter expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: fileListPresenter;
				   add: (SpBoxLayout newTopToBottom
						    add: (SpTabLayout new
								     add: recordsTablePresenter label: 'Records';
								     add: graphicTimeline label: 'Timeline';
								     yourself);
						    yourself);
				   yourself)
]

{ #category : 'layout' }
DSRecordBrowser >> fileList [
	"Instanciates a new presenter for the added files list."

	^ self newList
		  items: self files;
		  display: [ :file | file basenameWithoutExtension ];
		  actions: self listAddedFilesActions;
		  yourself
]

{ #category : 'accessing' }
DSRecordBrowser >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'layout' }
DSRecordBrowser >> filterRecordsButton [
	"Instanciates a new layout button that opens the records filter window."

	^ SpToolbarButtonPresenter new
		  label: 'Filter';
		  icon: (self iconNamed: #diff);
		  help: 'Filter the records.';
		  action: [ recordsFilter open ];
		  yourself
]

{ #category : 'helpers' }
DSRecordBrowser >> getHistoryFrom: aFileReference [

	^ DSRecordHistory on: (DSSpy materialize: aFileReference)
]

{ #category : 'helpers' }
DSRecordBrowser >> getRecordColorAssociationsFrom: aWindowRecordCollection [
	"Returns a dictionary associating each reacord with its window corresponding color, sorted by each reacord dateTime."

	| recordColorsDictionary |
	recordColorsDictionary := Dictionary new.

	aWindowRecordCollection do: [ :windowRecord |
		windowRecord events do: [ :record | recordColorsDictionary at: record put: (self getWindowColorFrom: windowRecord) ] ].

	^ recordColorsDictionary associations sorted: [ :recordA :recordB | recordA key dateTime < recordB key dateTime ]
]

{ #category : 'helpers' }
DSRecordBrowser >> getTimelinePointsFrom: aHistory [
	"Returns a list of plots for the timeline chart."

	^ aHistory windows collectWithIndex: [ :w :index |
			  RSTimeLinePlot new
				  entries: {
						  w events first dateTime asNanoSeconds.
						  w events last dateTime asNanoSeconds }
				  at: index;
				  color: (self getWindowColorFrom: w) ]
]

{ #category : 'color' }
DSRecordBrowser >> getWindowColorFrom: aWindowRecord [
	"Returns the window associated color, and the default color otherwise."

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

{ #category : 'initialization' }
DSRecordBrowser >> initializePresenters [

	startRecordButtonPresenter := self startRecordButton.
	stopRecordButtonPresenter := self stopRecordButton.
	toolbarPresenter := self toolbar.
	fileListPresenter := self fileList.
	recordsTablePresenter := self recordsTable.
	graphicTimeline := self newRoassal.
	recordsFilter := self recordsFilter
]

{ #category : 'operations' }
DSRecordBrowser >> listAddedFilesActions [
	"List actions for the added files in browser, such as inspecting raw records, inspecting history, or removing the selected file from the list."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  iconName: #inspect;
					  description: 'Inspect the raw records';
					  shortcutKey: $i meta;
					  action: [ (DSSpy materialize: fileListPresenter selectedItem) inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect history';
					  iconName: #history;
					  description: 'Inspect the record history';
					  shortcutKey: $h meta;
					  action: [ (self getHistoryFrom: fileListPresenter selectedItem) inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Remove';
					  iconName: #remove;
					  description: 'Remove the record from list';
					  shortcutKey: $x meta;
					  action: [ self removeFile: fileListPresenter selectedItem ] ];
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

	^ timerWindow
]

{ #category : 'layout' }
DSRecordBrowser >> recordsFilter [

	^ SpChooserPresenter new sourceItems: DSAbstractEventRecord getNonAbstractSubClasses 
]

{ #category : 'layout' }
DSRecordBrowser >> recordsTable [

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   title: 'Event';
				   displayBackgroundColor: [ :association | association value ];
				   evaluated: [ :association | association key eventName asString ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Event type';
				   displayBackgroundColor: [ :association | association value ];
				   evaluated: [ :association | association key class asString ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Time';
				   displayBackgroundColor: [ :association | association value ];
				   evaluated: [ :association | association key dateTime asTime print24 ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  beResizable;
		  actions: self recordsTableActions;
		  yourself
]

{ #category : 'operations' }
DSRecordBrowser >> recordsTableActions [
	"List actions that can be done on a record in the table, such as inspecting it."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  iconName: #inspect;
					  description: 'Inspect the raw records';
					  shortcutKey: $i meta;
					  action: [ recordsTablePresenter selectedItem key inspect ] ];
		  yourself
]

{ #category : 'files' }
DSRecordBrowser >> removeFile: aFileReference [

	files := files reject: [ :fileReference | fileReference = aFileReference ].
	fileListPresenter items: self files.
	fileListPresenter selectItem: (files ifNotEmpty: [ files last ])
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

	timerWindow := DSTimerWindow new.
	timerWindow 
		openInWorld;
		startTimer.
	DSSpyInstrumenter instrumentSystem.
	self updateToolbar
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
	timerWindow stopTimer.
	self currentWorld removeMorph: timerWindow.
	self updateToolbar
]

{ #category : 'layout' }
DSRecordBrowser >> timelineChart [

	| history names chart data |
	fileListPresenter selectedItem ifNil: [ ^ nil ].

	history := self getHistoryFrom: fileListPresenter selectedItem.
	names := history windows collect: [ :i | i getWindowType ].

	data := self getTimelinePointsFrom: history.
	data size < 2 ifTrue: [ ^ nil ].

	chart := RSCompositeChart new.
	chart addAll: data.

	chart verticalTick fromNames: names.

	chart horizontalTick
		useNiceLabel;
		numberOfTicks: history windows size // 2;
		useDiagonalLabel;
		labelConversion: [ :v | (DateAndTime fromSeconds: v // 1000000000) asTime ]. 
		
		"Plots are instancied using their dateTime as nano seconds to prevent events that last less than a second to be hided, so we convert them into seconds to get the label."

	chart build.
	^ chart
]

{ #category : 'layout' }
DSRecordBrowser >> toolbar [
	"Instanciates a new toolbar to be displayed on layout."

	^ self newToolbar
		  addItem: self addRecordButton;
		  addItem: startRecordButtonPresenter;
		  addItem: stopRecordButtonPresenter;
		  addItem: self filterRecordsButton
]

{ #category : 'operations' }
DSRecordBrowser >> updateRecordsTable: filesPresenter [
	"Updates the records presenter and add to each record its corresponding color."

	| fileRef recordColorAssociations |
	recordColorAssociations := Array new.
	fileRef := filesPresenter selectedItem.

	fileRef ifNotNil: [
			recordColorAssociations := self getRecordColorAssociationsFrom: (self getHistoryFrom: fileRef) windows.
			recordColorAssociations := recordColorAssociations reject: [ :association |
				                           recordsFilter chosenItems includes: association key class ] ].

	recordsTablePresenter roots: recordColorAssociations 
]

{ #category : 'operations' }
DSRecordBrowser >> updateTimelineChart [
	"Regenerates the timeline chart using the selected record's data"

	| chart |
	chart := self timelineChart.
	chart
		ifNil: [ graphicTimeline script: [ :canvas |  ] ]
		ifNotNil: [ graphicTimeline script: [ :canvas | chart renderIn: canvas ] ].
	graphicTimeline refresh
]

{ #category : 'layout' }
DSRecordBrowser >> updateToolbar [

	startRecordButtonPresenter enabled: DSSpy recordingSession not.
	stopRecordButtonPresenter enabled: DSSpy recordingSession
]

{ #category : 'accessing' }
DSRecordBrowser >> windowIcon [

	^ self iconNamed: #smallObjects 
]

{ #category : 'accessing' }
DSRecordBrowser >> windowTitle [

	^ 'Debugging record browser'
]

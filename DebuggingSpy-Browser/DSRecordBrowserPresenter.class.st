"
Debugging Spy main interface which includes :
- an opening button on the topside bar of the Pharo IDE
- buttons to start/stop the system instrumentation
- a window to visualize data from recording files
"
Class {
	#name : 'DSRecordBrowserPresenter',
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

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> colorAssociations [
	"Return all associations between the color and the corresponding window type."

	| method methodClass |
	^ (Pragma allNamed: #DSWindowColor) collect: [ :pragma |
			  method := pragma method.
			  methodClass := method methodClass.
			  (method valueWithReceiver: methodClass) -> (methodClass >> #windowType valueWithReceiver: methodClass) ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> defaultExtent [

	^ 1000 @ 600
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> defaultWindowColor [
	"Returns the default color for windows."

	^ Color fromHexString: '#b3b3b3'
]

{ #category : 'world menu' }
DSRecordBrowserPresenter class >> menuCommandOn: aBuilder [
	"Adds the DSSpy button on topside bar."

	<worldMenu>
	(aBuilder item: #DSSpy)
		order: 100;
		help: 'Open the Debugging Spy browser.';
		action: [ self toggleBrowser ]
]

{ #category : 'initialization' }
DSRecordBrowserPresenter class >> resetBrowser [
	"Removes the actual browser then another one will be created the next time it needs to be opened."

	<script>
	uniqueInstance := nil
]

{ #category : 'open/close' }
DSRecordBrowserPresenter class >> toggleBrowser [
	"Opens the browser or closes it depending on its state. If it needs to be created, then creates and opens it."

	uniqueInstance ifNotNil: [
			uniqueInstance hasWindow ifTrue: [
					^ uniqueInstance window isOpen
						  ifTrue: [ uniqueInstance window close ]
						  ifFalse: [ uniqueInstance window open ] ] ].
	self uniqueInstance open
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> uniqueInstance [
	"Returns the unique browser instance and instanciates it if needed."

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> windowColorFrom: anObject [
	"If the specified object is nil, returns the default windowColor, else return its window color."

	anObject ifNil: [ ^ self defaultWindowColor ].
	^ anObject windowColor
]

{ #category : 'files' }
DSRecordBrowserPresenter >> addFile: aFileReference [
	"Adds a file in the presenter and set is as selected, which updates the records displayed."

	(files includes: aFileReference)
		ifTrue: [ ^ self inform: 'File already added !' ]
		ifFalse: [
				files add: aFileReference.
				fileListPresenter items: files.
				fileListPresenter selectItem: aFileReference ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> addRecordButton [
	"Layout button which opens a window for selecting files."

	^ SpToolbarButtonPresenter new
		  label: 'Add';
		  icon: (self iconNamed: #smallAdd);
		  help: 'Add a new record.';
		  action: [ self openAddFileDialog ];
		  yourself
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> colorReferential [
	"Instanciates a new table that displays the color referential."

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   title: 'Color';
				   evaluated: [ ];
				   displayBackgroundColor: [ :association | association key ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Window type';
				   evaluated: [ :association | association value ];
				   displayColor: [ :aRecord | Color white ];
				   yourself);
		  roots: self class colorAssociations;
		  beResizable;
		  yourself
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> connectPresenters [
	"Updates the records and the timeline whenever the selected file is changed."

	fileListPresenter whenSelectionChangedDo: [ :presenter |
			self updateRecordsTable: presenter.
			self updateTimelineChart ].

	recordsFilter whenChangedDo: [ fileListPresenter selectedItem ifNotNil: [ self updateRecordsTable: fileListPresenter ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: toolbarPresenter expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: (SpPanedLayout newTopToBottom
						    add: fileListPresenter;
						    add: self colorReferential;
						    positionOfSlider: 57 percent;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    add: (SpTabLayout new
								     add: recordsTablePresenter label: 'Records';
								     add: graphicTimeline label: 'Timeline';
								     yourself);
						    yourself);
				   yourself)
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> fileList [
	"Instanciates a new presenter with a list of added files."

	^ self newList
		  items: self files;
		  display: [ :file | file basenameWithoutExtension ];
		  actions: self listAddedFilesActions;
		  yourself
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> filterRecordsButton [
	"Instanciates a new layout button which opens the records' filter window."

	^ SpToolbarButtonPresenter new
		  label: 'Filter';
		  icon: (self iconNamed: #diff);
		  help: 'Filter records.';
		  action: [ recordsFilter open ];
		  yourself
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getHistoryFrom: aFileReference [
	"Returns the generated history using the specified file reference which should countains DSSpy records."

	^ DSRecordHistory on: (DSSpy materialize: aFileReference)
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getRecordColorAssociationsFrom: aWindowRecordCollection [
	"Returns a sorted collection associating each record with its window's corresponding color, sorted by record's dateTime."

	| recordColorsAssociations |
	recordColorsAssociations := OrderedCollection new.

	aWindowRecordCollection do: [ :windowRecord |
		recordColorsAssociations addAll:
			(windowRecord events collect: [ :record | record -> windowRecord windowColor ]) ].

	^ recordColorsAssociations sorted: [ :recordA :recordB | recordA key dateTime < recordB key dateTime ]
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getTimelinePointsFrom: aHistory [
	"Returns a list of plots for the timeline chart."

	^ aHistory windows collectWithIndex: [ :windowRecord :index |
			  RSTimeLinePlot new
				  entries: {
						  windowRecord events first dateTime asNanoSeconds.
						  windowRecord events last dateTime asNanoSeconds }
				  at: index;
				  color: windowRecord windowColor ]
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> initializePresenters [

	startRecordButtonPresenter := self startRecordButton.
	stopRecordButtonPresenter := self stopRecordButton.
	toolbarPresenter := self toolbar.
	fileListPresenter := self fileList.
	recordsTablePresenter := self recordsTable.
	graphicTimeline := self newRoassal.
	recordsFilter := self recordsFilter
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> listAddedFilesActions [
	"Returns a list of actions for the list of added files. Action are: inspecting raw records, inspecting history, or removing the selected file from the list."

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
DSRecordBrowserPresenter >> openAddFileDialog [
	"Opens a dialog where the user can select a file to add in the browser."

	| filesDirectory newFiles |
	filesDirectory := DSSpy logger loggingDirectory.
	filesDirectory ensureCreateDirectory.

	newFiles := StOpenFilePresenter new
		            beMultipleSelection;
		            defaultFolder: filesDirectory;
		            openModal.

	newFiles ifNotNil: [ newFiles do: [ :file | self addFile: file asFileReference ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> recordsFilter [
	"Instanciates a new chooser that displays every record classes that could be used to filter records in table."

	^ SpChooserPresenter new sourceItems: DSAbstractEventRecord getLeafSubClasses
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> recordsTable [
	"Instanciates a new records table that displays data based on the selected file's records."

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
DSRecordBrowserPresenter >> recordsTableActions [
	"Return a list of actions which can be done on a record from the table. For example, inspect the selected record."

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
DSRecordBrowserPresenter >> removeFile: aFileReference [
	"Removes the selected file from the list and updates the selected item depending on the list number of elements."

	files := files reject: [ :fileReference | fileReference = aFileReference ].
	fileListPresenter items: self files.
	fileListPresenter selectItem: (files ifNotEmpty: [ files last ])
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> startRecordButton [
	"Instanciates a button that starts the DSSpy recording session on click."

	^ SpToolbarButtonPresenter new
		  label: 'Start';
		  icon: (self iconNamed: #glamorousGo);
		  help: 'Start recording events.';
		  action: [ self startRecording ];
		  enabled: DSSpy recordingSession not;
		  yourself
]

{ #category : 'recording' }
DSRecordBrowserPresenter >> startRecording [
	"Starts recording events and instianciates a timerWindow which displays a timer and shows that Debugging Spy is recording."

	timerWindow := DSTimerWindow new
		               openInWorld;
		               yourself.
	DSSpyInstrumenter instrumentSystem.
	timerWindow startTimer.
	self updateToolbar
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> stopRecordButton [
	"Instanciates a button that stops the DSSpy recording session on click."

	^ SpToolbarButtonPresenter new
		  label: 'Stop';
		  icon: (self iconNamed: #stop);
		  help: 'Stop recording events.';
		  action: [ self stopRecording ];
		  enabled: DSSpy recordingSession;
		  yourself
]

{ #category : 'recording' }
DSRecordBrowserPresenter >> stopRecording [
	"Stops the recording session and closes the timer window."

	DSSpyInstrumenter stopInstrumentation.
	self currentWorld removeMorph: timerWindow.
	self updateToolbar.
	timerWindow := nil
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> timelineChart [
	"Returns a chart that represents a timeline using the file list presenter's data for its plots."

	| history names chart data |
	fileListPresenter selectedItem ifNil: [ ^ nil ].

	history := self getHistoryFrom: fileListPresenter selectedItem.
	names := history windows collect: [ :i | i windowType ].

	data := self getTimelinePointsFrom: history.
	data size < 2 ifTrue: [ ^ nil ].

	chart := RSCompositeChart new.
	chart addAll: data.

	chart verticalTick fromNames: names.

	chart horizontalTick
		useNiceLabel;
		numberOfTicks: history windows size // 2;
		useDiagonalLabel;
		labelConversion: [ :v | (DateAndTime fromSeconds: v // 1000000000) asTime ]. "Plots are instancied using their dateTime as nano seconds to prevent events which last less than a second to be hided, so we convert them into seconds to get the label."

	chart build.
	^ chart
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> timerWindow [

	^ timerWindow
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> timerWindow: aTimerWindow [

	timerWindow := aTimerWindow
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> toolbar [
	"Instanciates a new toolbar to be displayed on layout."

	^ self newToolbar
		  addItem: self addRecordButton;
		  addItem: startRecordButtonPresenter;
		  addItem: stopRecordButtonPresenter;
		  addItem: self filterRecordsButton
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateLastRecord: aRecord [
	"Updates the last record for the recording window."

	timerWindow ifNil: [ ^ self ].
	timerWindow lastRecord: aRecord
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateRecordsTable: filesPresenter [
	"Updates the records' table presenter and add to each record its corresponding color."

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
DSRecordBrowserPresenter >> updateTimelineChart [
	"Regenerates the timeline chart using the selected record's data"

	| chart |
	chart := self timelineChart.
	chart
		ifNil: [ graphicTimeline script: [ :canvas |  ] ]
		ifNotNil: [ graphicTimeline script: [ :canvas | chart renderIn: canvas ] ].
	graphicTimeline refresh
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> updateToolbar [

	startRecordButtonPresenter enabled: DSSpy recordingSession not.
	stopRecordButtonPresenter enabled: DSSpy recordingSession
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowIcon [

	^ self iconNamed: #smallObjects 
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowTitle [

	^ 'Debugging record browser'
]

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
		'recordsFilter',
		'toolbarPresenter',
		'fileListPresenter',
		'startRecordButtonPresenter',
		'stopRecordButtonPresenter',
		'windowsPresenter',
		'statisticsPresenter',
		'selectedHistory'
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
DSRecordBrowserPresenter class >> defaultPreferredExtent [

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

	<script>
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

{ #category : 'windows' }
DSRecordBrowserPresenter class >> windowColor [

	<DSWindowColor>
	^ Color fromHexString: '#ec45ff'
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> windowColorFrom: anObject [
	"If the specified object is nil, returns the default windowColor, else return its window color."

	anObject ifNil: [ ^ self defaultWindowColor ].
	^ anObject windowColor
]

{ #category : 'accessing' }
DSRecordBrowserPresenter class >> windowType [

	^ 'Debugging Spy'
]

{ #category : 'files' }
DSRecordBrowserPresenter >> addFile: aFileReference [
	"Adds a file in the presenter and set is as selected, which updates the records displayed."

	(self isFileAdded: aFileReference)
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
				   evaluated: [ :association | '' ];
				   displayBackgroundColor: [ :association | association key ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Window type';
				   evaluated: [ :association | association value ];
				   yourself);
		  roots: (self class colorAssociations sort: [ :a :b | a key hue <= b key hue ]);
		  beResizable;
		  yourself
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> connectPresenters [
	"Updates the records and the timeline whenever the selected file is changed."

	fileListPresenter whenSelectionChangedDo: [
			selectedHistory := self getHistoryFrom: fileListPresenter selectedItem.
			self updateRecordsTable.
			self updateWindowsPresenter.
			self updateStatisticsPresenter ].

	recordsFilter whenChangedDo: [ self updateRecordsTable ]
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
								     add: windowsPresenter label: 'Windows';
								     add: statisticsPresenter label: 'Statistics';
								     yourself);
						    yourself);
				   yourself)
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> fileListPresenter [
	"Instanciates a new presenter with a list of added files."

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   evaluated: [ :file | file basenameWithoutExtension ];
				   beNotSortable;
				   yourself);
		  roots: self files;
		  children: [ :file |
				  file isDirectory
					  ifTrue: [ file children ]
					  ifFalse: [ {  } ] ];
		  actions: self fileListPresenterActions;
		  hideColumnHeaders
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> fileListPresenterActions [
	"Returns a list of actions for the list of added files. Action are: inspecting raw records, inspecting history, or removing the selected file from the list."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  iconName: #inspect;
					  description: 'Inspect the raw records';
					  shortcutKey: $i meta;
					  action: [ selectedHistory records inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect history';
					  iconName: #history;
					  description: 'Inspect the record history';
					  shortcutKey: $h meta;
					  action: [ selectedHistory inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Remove';
					  iconName: #remove;
					  description: 'Remove the record from list';
					  shortcutKey: $x meta;
					  action: [ self removeFile: fileListPresenter selectedItem ] ];
		  yourself
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> files [

	^ files ifNil: [ files := OrderedCollection new ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> files: newFiles [

	files := newFiles
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> filterRecordClass: aClass [
	"Add the specified class to the records filter."

	recordsFilter sourceList selectItems: { aClass }.
	recordsFilter addSelected
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

	aFileReference ifNil: [ ^ nil ].
	^ DSRecordHistory on: (self getRecordsFromFileReference: aFileReference)
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
DSRecordBrowserPresenter >> getRecordsFromFileReference: aFileReference [
	"Returns recursively a list of records taken in the specified file reference. If the argument is a folder, takes all its contained records."

	| records |
	aFileReference isDirectory ifFalse: [ ^ DSSpy materialize: aFileReference ].

	records := OrderedCollection new.
	records addAll: (aFileReference children collect: [ :fileRef | self getRecordsFromFileReference: fileRef ]).
	^ records flattened sorted: [ :a :b | a dateTime < b dateTime ]
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getWindowFromRecord: aRecord [
	"Returns the record's corresponding window record in the history."

	^ (selectedHistory windows select: [ :window | window windowId = aRecord windowId ]) first
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> initializePresenters [

	startRecordButtonPresenter := self startRecordButton.
	stopRecordButtonPresenter := self stopRecordButton.
	toolbarPresenter := self toolbar.
	fileListPresenter := self fileListPresenter.
	recordsTablePresenter := self recordsTable.
	recordsFilter := self recordsFilter.
	windowsPresenter := self windowsPresenter.
	statisticsPresenter := self statisticsPresenter
]

{ #category : 'testing' }
DSRecordBrowserPresenter >> isFileAdded: aFileReference [
	"Returns true if the specified file is already added in the files (or in a folder)."

	^ files anySatisfy: [ :fileRef | aFileReference pathString includesSubstring: fileRef pathString ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> openAddFileDialog [
	"Opens a dialog where the user can select a file to add in the browser."

	| filesDirectory newFiles |
	filesDirectory := DSSpy logger loggingDirectory.
	filesDirectory ensureCreateDirectory.

	newFiles := StOpenFileOrDirectoryPresenter new
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
				   displayBackgroundColor: [ :association | association key windowColor ];
				   width: 4;
				   beNotSortable;
				   evaluated: [ :association | '' ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Event';
				   evaluated: [ :association | association key eventName asString ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Type';
				   evaluated: [ :association | association key class asString ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Time';
				   evaluated: [ :association | association key printAsFormattedTime ];
				   yourself);
		  beResizable;
		  actions: self recordsTableActions;
		  yourself
]

{ #category : 'layout' }
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
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect the window';
					  iconName: #window;
					  description: 'Inspect the record window';
					  shortcutKey: $w meta;
					  action: [ (self getWindowFromRecord: recordsTablePresenter selectedItem key) inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Filter this type of records';
					  iconName: #packageAdd;
					  description: 'Filter this type of records';
					  shortcutKey: $f meta;
					  action: [ self filterRecordClass: recordsTablePresenter selectedItem key class ] ];
		  yourself
]

{ #category : 'files' }
DSRecordBrowserPresenter >> removeFile: aFileReference [
	"Removes the selected file from the list and updates the selected item depending on the list number of elements."

	files := files reject: [ :fileReference | fileReference = aFileReference ].
	fileListPresenter items: self files.
	fileListPresenter selectItem: (files ifNotEmpty: [ files last ])
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> selectedHistory [

	^ selectedHistory
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> selectedHistory: anHistory [

	selectedHistory := anHistory
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
DSRecordBrowserPresenter >> statisticsPresenter [
	"Instanciates a new records table that displays data based on the selected file's records."

	^ SpGridLayout new
		  beColumnNotHomogeneous;
		  yourself
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
DSRecordBrowserPresenter >> updateRecordsTable [
	"Updates the records' table presenter and add to each record its corresponding color."

	| recordColorAssociations |
	recordColorAssociations := Array new.

	selectedHistory ifNotNil: [
			recordColorAssociations := self getRecordColorAssociationsFrom: selectedHistory windows.
			recordColorAssociations := recordColorAssociations reject: [ :association |
				                           recordsFilter chosenItems includes: association key class ] ].

	recordsTablePresenter roots: recordColorAssociations
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateStatisticsPresenter [
	"Updates the different fields in the statistics presenter depending on the selected history."

	| stats |
	selectedHistory ifNil: [ ^ self ].
	stats := {
		         ('Number of events: ' , selectedHistory records size asString).
		         ('Number of windows: ' , selectedHistory windows size asString).
		         ('Time taken: ' , (Time fromSeconds: selectedHistory timeTaken) print24).
		         ('Idle time: ' , (Time fromSeconds: selectedHistory computeIdleTime) print24).
		         ('Absolute time taken: ' , (Time fromSeconds: selectedHistory absoluteTimeTaken) print24) }.

	stats doWithIndex: [ :stat :index | statisticsPresenter add: stat asPresenter atPoint: 1 @ index ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> updateToolbar [

	startRecordButtonPresenter enabled: DSSpy recordingSession not.
	stopRecordButtonPresenter enabled: DSSpy recordingSession
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateWindowsPresenter [
	"Updates the windows presenter by setting its roots using the selected item from files presenter."

	selectedHistory ifNil: [ windowsPresenter roots: {  } ] ifNotNil: [ windowsPresenter roots: selectedHistory windows ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowIcon [

	^ self iconNamed: #smallObjects 
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowTitle [

	^ 'Debugging record browser'
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> windowsPresenter [
	"Instanciates a new table that displays the windows and their events as children. For each column, the manipulated object could be either a DSWindowRecord or a record that inherits from DSAbstractEventRecord."

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   width: 4;
				   beNotSortable;
				   evaluated: [ :item | '' ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   width: 20;
				   beNotExpandable;
				   beNotSortable;
				   displayBackgroundColor: [ :anItem | anItem windowColor ];
				   evaluated: [ :item | '' ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Window / Event';
				   evaluated: [ :anItem | anItem asString ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Type';
				   evaluated: [ :anItem | anItem type ];
				   yourself);
		  addColumn: (SpStringTableColumn new
				   title: 'Time';
				   evaluated: [ :anItem | anItem printAsFormattedTime ];
				   yourself);
		  beResizable;
		  actions: self windowsPresenterActions;
		  children: [ :item |
				  item class = DSWindowRecord
					  ifTrue: [ item events ]
					  ifFalse: [ {  } ] ];
		  yourself
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> windowsPresenterActions [
	"Return a list of actions which can be done on a record from the table. For example, inspect the selected record."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  iconName: #inspect;
					  description: 'Inspect the selected element.';
					  shortcutKey: $i meta;
					  action: [ windowsPresenter selectedItem inspect ] ];
		  yourself
]

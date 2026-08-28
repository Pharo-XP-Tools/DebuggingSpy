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
		'selectedHistory',
		'recordTypesPresenter',
		'activityPresenter',
		'activityRecordsPresenter',
		'windowsRecordsPresenter'
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

{ #category : 'accessing' }
DSRecordBrowserPresenter >> activityLayout [
	"Returns the layout that displays the activity table and the selected records if applicable."

	^ SpPanedLayout newTopToBottom
		  add: activityPresenter;
		  add: activityRecordsPresenter;
		  positionOfSlider: 70 percent
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> activityPresenter [
	"Instanciates a new table that displays the windows and their events as children. For each column, the manipulated object could be either a DSWindowRecord or a record that inherits from DSAbstractEventRecord."

	| presenter |
	presenter := self newTreeTable.

	^ presenter
		  addColumn: (SpStringTableColumn new
				   width: 4;
				   beNotSortable;
				   displayBackgroundColor: [ :windowJump | windowJump windowColor ];
				   evaluated: [ :windowJump | '' ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Window';
				   evaluated: [ :windowJump | windowJump window asString ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Start';
				   evaluated: [ :windowJump | windowJump start printAsFormattedTime ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Stop';
				   evaluated: [ :windowJump | windowJump stop printAsFormattedTime ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Duration';
				   evaluated: [ :windowJump | windowJump duration ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Number of events';
				   evaluated: [ :windowJump | windowJump events size ]);
		  beResizable;
		  actions: (SpActionGroup new
				   add: (self commonActionsFor: presenter);
				   yourself)
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
		  action: [ self openAddFileDialog ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> colorReferential [
	"Instanciates a new table that displays the color referential."

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   title: 'Color';
				   evaluated: [ :association | '' ];
				   displayBackgroundColor: [ :association | association key ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Window type';
				   evaluated: [ :association | association value ]);
		  roots: (self class colorAssociations sort: [ :a :b | a key hue <= b key hue ]);
		  beResizable
]

{ #category : 'actions' }
DSRecordBrowserPresenter >> commonActionsFor: aPresenter [
	"Return a list of actions which can be done on every presenter."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect';
					  iconName: #inspect;
					  description: 'Inspect the selected item';
					  shortcutKey: $i meta;
					  action: [ aPresenter selectedItem inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect history';
					  iconName: #history;
					  description: 'Inspect the history';
					  shortcutKey: $h meta;
					  action: [ selectedHistory inspect ] ]
]

{ #category : 'initialization' }
DSRecordBrowserPresenter >> connectPresenters [
	"Updates the records and the timeline whenever the selected file is changed."

	fileListPresenter whenSelectionChangedDo: [
			selectedHistory := self getHistoryFrom: fileListPresenter selectedItem.
			self updateRecordsPresenter: recordsTablePresenter with: selectedHistory.

			self updateWindowsPresenter.
			self updateStatisticsPresenter.
			self updateRecordTypesPresenter.
			self updateActivityPresenter ].

	recordsFilter whenChangedDo: [
			self updateRecordsPresenter: recordsTablePresenter with: selectedHistory.
			self updateRecordsPresenter: windowsRecordsPresenter with: windowsPresenter selectedItem.
			self updateRecordsPresenter: activityRecordsPresenter with: activityPresenter selectedItem ].

	windowsPresenter whenSelectedItemChangedDo: [ :selectedItem |
		self updateRecordsPresenter: windowsRecordsPresenter with: selectedItem ].

	activityPresenter whenSelectedItemChangedDo: [ :selectedItem |
		self updateRecordsPresenter: activityRecordsPresenter with: selectedItem ]
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
						    positionOfSlider: 57 percent);
				   add: (SpTabLayout new
						    add: self activityLayout label: 'Activity';
						    add: recordsTablePresenter label: 'Records';
						    add: statisticsPresenter label: 'Statistics';
						    add: recordTypesPresenter label: 'Types';
						    add: self windowsLayout label: 'Windows'))
]

{ #category : 'actions' }
DSRecordBrowserPresenter >> fileActionsFor: aPresenter [
	"Return a list of actions which can be done on a file."

	^ SpActionGroup new addActionWith: [ :anItem |
			  anItem
				  name: 'Remove';
				  iconName: #remove;
				  description: 'Remove the file from list';
				  shortcutKey: $x meta;
				  action: [ self removeFile: aPresenter selectedItem ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> fileListPresenter [
	"Instanciates a new presenter with a list of added files."

	| presenter |
	presenter := self newTreeTable.
	^ presenter
		  addColumn: (SpStringTableColumn new
				   evaluated: [ :file | file basenameWithoutExtension ];
				   beNotSortable);
		  roots: self files;
		  children: [ :file |
				  file isDirectory
					  ifTrue: [ file children ]
					  ifFalse: [ {  } ] ];
		  actions: (SpActionGroup new
				   add: (self commonActionsFor: presenter);
				   add: (self fileActionsFor: presenter));
		  hideColumnHeaders
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
		  action: [ recordsFilter open ]
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getHistoryFrom: aFileReference [
	"Returns the generated history using the specified file reference which should countains DSSpy records."

	aFileReference ifNil: [ ^ nil ].
	^ DSRecordHistory on: (self getRecordsFromFileReference: aFileReference)
]

{ #category : 'helpers' }
DSRecordBrowserPresenter >> getNumberOfEventsPerType [
	"Returns a list of dictionary that associates each type of records to the number of records of this type in the selected history."

	| dict |
	dict := Dictionary new.
	selectedHistory ifNotNil: [
			selectedHistory events do: [ :record |
					(dict includesKey: record class)
						ifTrue: [ dict at: record class update: [ :nbOfRecords | nbOfRecords + 1 ] ]
						ifFalse: [ dict at: record class put: 1 ] ] ].
	^ dict
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
	recordsTablePresenter := self recordsPresenter.
	recordsFilter := self recordsFilter.
	windowsPresenter := self windowsPresenter.
	statisticsPresenter := self statisticsPresenter.
	recordTypesPresenter := self recordTypesPresenter.
	activityPresenter := self activityPresenter.
	windowsRecordsPresenter := self recordsPresenter.
	activityRecordsPresenter := self recordsPresenter
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
DSRecordBrowserPresenter >> recordTypesPresenter [
	"Instanciates a new table that displays the record types and some information about them."

	^ self newTreeTable
		  addColumn: (SpStringTableColumn new
				   title: 'Type';
				   evaluated: [ :association | association key name ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Number of records';
				   evaluated: [ :association | association value ]);
		  beResizable
]

{ #category : 'actions' }
DSRecordBrowserPresenter >> recordsActionsFor: aPresenter [
	"Return a list of actions which can be done on a record."

	^ SpActionGroup new
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Inspect the window';
					  iconName: #window;
					  description: 'Inspect the record window';
					  shortcutKey: $w meta;
					  action: [ (self getWindowFromRecord: aPresenter selectedItem) inspect ] ];
		  addActionWith: [ :anItem |
				  anItem
					  name: 'Filter this type of records';
					  iconName: #packageAdd;
					  description: 'Filter this type of records';
					  shortcutKey: $f meta;
					  action: [ self filterRecordClass: aPresenter selectedItem class ] ]
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> recordsFilter [
	"Instanciates a new chooser that displays every record classes that could be used to filter records in table."

	^ SpChooserPresenter new sourceItems: DSAbstractEventRecord getLeafSubClasses
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> recordsPresenter [
	"Instanciates a new records table that displays data based on the selected records in windows or activity tabs."

	| presenter |
	presenter := self newTreeTable.

	^ presenter
		  addColumn: (SpStringTableColumn new
				   displayBackgroundColor: [ :record | record windowColor ];
				   width: 4;
				   beNotSortable;
				   evaluated: [ :record | '' ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Event';
				   evaluated: [ :record | record asString ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Type';
				   evaluated: [ :record | record class name ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Time';
				   evaluated: [ :record | record printAsFormattedTime ]);
		  actions: (SpActionGroup new
				   add: (self commonActionsFor: presenter);
				   add: (self recordsActionsFor: presenter));
		  beResizable
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
		  enabled: DSSpy recordingSession not
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

	^ SpGridLayout new beColumnNotHomogeneous
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> stopRecordButton [
	"Instanciates a button that stops the DSSpy recording session on click."

	^ SpToolbarButtonPresenter new
		  label: 'Stop';
		  icon: (self iconNamed: #stop);
		  help: 'Stop recording events.';
		  action: [ self stopRecording ];
		  enabled: DSSpy recordingSession
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
DSRecordBrowserPresenter >> updateActivityPresenter [
	"Updates the activity presenter by setting its roots using the selected history."

	selectedHistory ifNil: [ activityPresenter roots: {  } ] ifNotNil: [ activityPresenter roots: selectedHistory windowJumps ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateLastRecord: aRecord [
	"Updates the last record for the recording window."

	timerWindow ifNil: [ ^ self ].
	timerWindow lastRecord: aRecord
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateRecordTypesPresenter [
	"Updates the record types presenter by setting its roots using the selected history."

	selectedHistory
		ifNil: [ recordTypesPresenter roots: {  } ]
		ifNotNil: [ recordTypesPresenter roots: self getNumberOfEventsPerType associations ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateRecordsPresenter: aRecordPresenter with: anEventsContainer [
	"Update a record presenter using an object that defines a method returning its events."
	
	anEventsContainer
		ifNil: [ aRecordPresenter roots: {  } ]
		ifNotNil: [
		aRecordPresenter roots: (anEventsContainer events reject: [ :event | recordsFilter chosenItems includes: event class ]) ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateStatisticsPresenter [
	"Updates the different fields in the statistics presenter depending on the selected history."

	| stats |
	selectedHistory ifNil: [ ^ self ].
	stats := {
		         ('Number of events: ' , selectedHistory events size asString).
		         ('Number of windows: ' , selectedHistory windows size asString).
		         ('Time taken: ' , (Time fromSeconds: selectedHistory timeTaken) print24).
		         ('Idle time: ' , (Time fromSeconds: selectedHistory computeIdleTime) print24).
		         ('Absolute time taken: ' , (Time fromSeconds: selectedHistory absoluteTimeTaken) print24).
		         ('Number of debug actions: ' , selectedHistory countDebugActions asString).
		         ('Date: ' , selectedHistory dateTime asString).
		         ('Debug points added: ' , selectedHistory debugPointAdds asString).
		         ('Debug points hit: ' , selectedHistory debugPointHit asString).
		         ('Debug points removed: ' , selectedHistory debugPointRemoved asString).
		         ('Methods added: ' , selectedHistory methodsAdded asString).
		         ('Methods modified: ' , selectedHistory methodsModified asString).
		         ('Methods removed: ' , selectedHistory methodsRemoved asString).
		         ('Number of steps: ' , selectedHistory numberOfSteps asString).
		         ('Executed code: ' , selectedHistory executedCode asString) }.

	stats doWithIndex: [ :stat :index | statisticsPresenter add: stat asPresenter atPoint: 1 @ index ]
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateToolbar [

	startRecordButtonPresenter enabled: DSSpy recordingSession not.
	stopRecordButtonPresenter enabled: DSSpy recordingSession
]

{ #category : 'operations' }
DSRecordBrowserPresenter >> updateWindowsPresenter [
	"Updates the windows presenter by setting its roots using the selected history."

	selectedHistory ifNil: [ windowsPresenter roots: {  } ] ifNotNil: [ windowsPresenter roots: selectedHistory windows ]
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowIcon [

	^ self iconNamed: #smallObjects 
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowTitle [

	^ 'Debugging Spy browser'
]

{ #category : 'accessing' }
DSRecordBrowserPresenter >> windowsLayout [
	"Returns the layout that displays the windows table and the selected records if applicable."

	^ SpPanedLayout newTopToBottom
		  add: windowsPresenter;
		  add: windowsRecordsPresenter;
		  positionOfSlider: 70 percent
]

{ #category : 'layout' }
DSRecordBrowserPresenter >> windowsPresenter [
	"Instanciates a new table that displays the windows and their events as children. For each column, the manipulated object could be either a DSWindowRecord or a record that inherits from DSAbstractEventRecord."

	| presenter |
	presenter := self newTreeTable.

	^ presenter
		  addColumn: (SpStringTableColumn new
				   width: 4;
				   beNotSortable;
				   displayBackgroundColor: [ :window | window windowColor ];
				   evaluated: [ :window | '' ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Window';
				   evaluated: [ :window | window asString ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Duration';
				   evaluated: [ :window | window printAsFormattedTime ]);
		  addColumn: (SpStringTableColumn new
				   title: 'Number of events';
				   evaluated: [ :window | window events size ]);
		  beResizable;
		  actions: (self commonActionsFor: presenter)
]

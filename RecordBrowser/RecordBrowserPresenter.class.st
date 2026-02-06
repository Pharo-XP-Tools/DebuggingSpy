"
Record browser for DsSpy data.
"
Class {
	#name : 'RecordBrowserPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'files',
		'listPresenter',
		'addButton',
		'toolbar',
		'selectedRecordsPresenter',
		'selectedRecords'
	],
	#category : 'RecordBrowser',
	#package : 'RecordBrowser'
}

{ #category : 'adding' }
RecordBrowserPresenter >> addFile: aFileReference [

	files add: aFileReference.
	listPresenter items: files.
	self updateContentViewer: aFileReference
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
				   add: listPresenter;
				   add: selectedRecordsPresenter;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
RecordBrowserPresenter >> files [

	^ files
]

{ #category : 'initialization' }
RecordBrowserPresenter >> initializePresenters [

	files := OrderedCollection new.

	addButton := SpToolbarButtonPresenter new
		             label: 'Add';
		             icon: (self iconNamed: #smallAdd);
		             help: 'Add a new record';
		             action: [ self openAddFileDialog ];
		             yourself.

	toolbar := self newToolbar addItem: addButton.

	listPresenter := self newList
		                 items: files;
		                 display: [ :file | file basenameWithoutExtension ];
		                 whenSelectionChangedDo: [ :file | file ifNotNil: [ self updateContentViewer: file selectedItem ] ].

	selectedRecordsPresenter := self newTreeTable
		                            addColumn: (SpStringTableColumn title: 'Event type' evaluated: [ :item | item eventName asString ]);
		                            addColumn: (SpStringTableColumn title: 'Date' evaluated: [ :item | item dateTime asString ]);
		                            beResizable;
		                            yourself
]

{ #category : 'operations' }
RecordBrowserPresenter >> openAddFileDialog [

	| fileNames |
	fileNames := StOpenFilePresenter new
		             defaultFolder: DSSpy logger loggingDirectory;
		             openModal.
	fileNames do: [ :file | self addFile: file asFileReference ]
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

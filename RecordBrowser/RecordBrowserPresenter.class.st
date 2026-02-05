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
		'fileContent'
	],
	#category : 'RecordBrowser',
	#package : 'RecordBrowser'
}

{ #category : 'adding' }
RecordBrowserPresenter >> addFile: newFile [

	files add: newFile.
	listPresenter items: files
]

{ #category : 'layout' }
RecordBrowserPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: toolbar expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: listPresenter;
				   add: fileContent;
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

	fileContent := self newText beNotEditable
]

{ #category : 'operations' }
RecordBrowserPresenter >> openAddFileDialog [

	| fileNames |
	fileNames := StOpenFilePresenter chooseModal.
	fileNames do: [ :file | self addFile: file asFileReference ]
]

{ #category : 'operations' }
RecordBrowserPresenter >> updateContentViewer: aFileReference [

	fileContent text: aFileReference contents
]

{ #category : 'accessing' }
RecordBrowserPresenter >> windowTitle [

	^ 'Debugging record browser'
]

"
Record when a user is doing a ""Browse"" on a class, method, ...
"
Class {
	#name : 'DSBrowseRecord',
	#superclass : 'DSAbstractBrowserRecord',
	#instVars : [
		'packageBrowsed',
		'classBrowsed',
		'methodBrowsed'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSBrowseRecord >> classBrowsed [ 

	^ classBrowsed 
]

{ #category : 'accessing' }
DSBrowseRecord >> eventName [
	^ 'Browse'
]

{ #category : 'accessing' }
DSBrowseRecord >> methodBrowsed [ 

	^ methodBrowsed 
]

{ #category : 'accessing' }
DSBrowseRecord >> packageBrowsed [ 

	^ packageBrowsed 
]

{ #category : 'accessing' }
DSBrowseRecord >> record: aClyBrowser [

	windowId := aClyBrowser window identityHash.
	packageBrowsed := aClyBrowser packageSelection isEmpty
		                  ifTrue: [ '' ]
		                  ifFalse: [ 
		                  aClyBrowser packageSelection lastSelectedItem
			                  actualObject name ].
	classBrowsed := aClyBrowser classSelection isEmpty
		                ifTrue: [ '' ]
		                ifFalse: [ 
		                aClyBrowser classSelection lastSelectedItem
			                actualObject name ].
	methodBrowsed := aClyBrowser methodSelection isEmpty
		                 ifTrue: [ '' ]
		                 ifFalse: [ 
		                 aClyBrowser methodSelection lastSelectedItem
			                 actualObject name ].
]

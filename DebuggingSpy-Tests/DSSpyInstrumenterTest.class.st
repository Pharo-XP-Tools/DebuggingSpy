Class {
	#name : #DSSpyInstrumenterTest,
	#superclass : #TestCase,
	#instVars : [
		'modifiedClass',
		'modifiedMethodSource',
		'instrumenter'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #helpers }
DSSpyInstrumenterTest >> registry [
	^DSRecordRegistry current records
]

{ #category : #running }
DSSpyInstrumenterTest >> setUp [
	super setUp.
	
	instrumenter := DSSpyInstrumenter new.
	DSRecordRegistry current reset
]

{ #category : #running }
DSSpyInstrumenterTest >> tearDown [

	(modifiedClass notNil and: [ 
		 (#( nil '' ) includes: modifiedMethodSource) not ]) ifTrue: [ 
		modifiedClass compile: modifiedMethodSource ].
	DSRecordRegistry current reset.
	super tearDown
]

{ #category : #tests }
DSSpyInstrumenterTest >> testInstrumentClyFullBrowser [
	|browser record|
	modifiedClass := ClyFullBrowser.
	modifiedMethodSource := (ClyFullBrowser >> #newWindowTitle) sourceCode.
	instrumenter instrumentClyFullBrowserWindowTitle.
	browser := ClyFullBrowser on: ClyNavigationEnvironment currentImage.  
	browser  prepareInitialStateBy:  [ :b |b selectMethod: (Object>>#yourself)].
	browser newWindowTitle.
	
	self assert: self registry size equals: 1.
	
	record := self registry first.
	self assert: record class identicalTo: DSFullBrowseRecord.
	self assert: record windowId equals: browser window hash.
	self assert: record classBrowsed equals: Object name.
	self assert: record packageBrowsed equals: Object package name.
	self assert: record methodBrowsed equals: (Object>>#yourself) name
]

Class {
	#name : #DSSpyInstrumenterTest,
	#superclass : #TestCase,
	#instVars : [
		'modifiedClass',
		'modifiedMethodSource',
		'instrumenter',
		'record',
		'debugger',
		'browser',
		'methodToRemove'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #helpers }
DSSpyInstrumenterTest >> debuggerForTesting [

	^ StTestDebuggerProvider new debuggerWithObjectHalting
		  application: StDebugger currentApplication;
		  initialize
]

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

{ #category : #helpers }
DSSpyInstrumenterTest >> simulatedMouseEventFor: morph [

	^ MouseMoveEvent new
		  setType: #mouseMove
		  startPoint: 4
		  endPoint: 2
		  trail: nil
		  buttons: 0
		  hand: (HandMorph new mouseFocus: morph; yourself)
		  stamp: 0
]

{ #category : #running }
DSSpyInstrumenterTest >> tearDown [

	(modifiedClass notNil and: [ 
		 (#( nil '' ) includes: modifiedMethodSource) not ]) ifTrue: [ 
		modifiedClass compile: modifiedMethodSource.
		modifiedClass := nil.
		modifiedMethodSource := nil ].
	methodToRemove ifNotNil: [ 
		methodToRemove removeFromSystem.
		methodToRemove := nil ].
	DSRecordRegistry current reset.
	super tearDown
]

{ #category : #'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentClyFullBrowser [

	modifiedClass := ClyFullBrowser.
	modifiedMethodSource := (ClyFullBrowser >> #newWindowTitle) sourceCode.
	instrumenter instrumentClyFullBrowser.
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

{ #category : #'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentClyQueryBrowser [
	
	modifiedClass := ClyQueryBrowser.
	modifiedMethodSource := (ClyQueryBrowser >> #newWindowTitle) sourceCode.
	instrumenter instrumentClyQueryBrowser.
	browser := ClyQueryBrowser on: ClyNavigationEnvironment currentImage.  
	browser showResultOf: (ClyMessageImplementorsQuery of: #instrumentClyQueryBrowser).
	browser newWindowTitle.
	
	self assert: self registry size equals: 1.
	
	record := self registry first.
	self assert: record class identicalTo: DSQueryBrowseRecord.
	self assert: record windowId equals: browser window hash.
	self assert: record queryName equals: browser systemQuery description
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerStack [
	|selectedItem|
	modifiedClass := StDebugger.
	modifiedMethodSource := (StDebugger >> #initializeStack) sourceCode.
	instrumenter instrumentDebuggerStack.
	
	debugger := self debuggerForTesting.	
	self assert: self registry size equals: 1.
	
	debugger stackTable selectItem: debugger stackTable items second.
	self assert: self registry size equals: 2.
	
	record := self registry second.
	selectedItem := debugger stackTable items second.
	self assert: record class identicalTo: DSBrowseContextRecord.
	self assert: record windowId equals: debugger window hash.
	self assert: record contextName equals: selectedItem method printString.
	self assert: record sourceNodeClass equals: selectedItem sourceNodeExecuted class name.
	self assert: record sourceNodeCode equals: selectedItem sourceNodeExecuted sourceCode.
	self assert: record receiver equals: selectedItem receiver printString.
	self assert: record selector equals: selectedItem selector
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseDownFTSelectableMorph [
	
	|morph|
	self should: [FTSelectableMorph >> #mouseDown: ] raise: KeyNotFound.
	instrumenter instrumentMouseDownFTSelectableMorph.
	methodToRemove := (FTSelectableMorph >> #mouseDown:).
	
	morph := FTSelectableMorph new.
	morph privateOwner: SystemWindow new.
	morph mouseDown: nil.
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseDownTableItemRecord.
	self assert: record windowId equals: morph window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {morph})
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseEnterFTSelectableMorph [
	
	|morph|
	modifiedClass := FTSelectableMorph.
	modifiedMethodSource := (FTSelectableMorph >> #mouseEnter:) sourceCode.
	instrumenter instrumentMouseEnterFTSelectableMorph.
	
	morph := FTSelectableMorph new.
	morph privateOwner: SystemWindow new.
	morph mouseEnter: nil.
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterTableItemRecord.
	self assert: record windowId equals: morph window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {morph})
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseEnterWindow [
	
	|window|
	self should: [SystemWindow >> #handleMouseEnter: ] raise: KeyNotFound.
	instrumenter instrumentMouseEnterWindow.
	methodToRemove := (SystemWindow >> #handleMouseEnter:).
	
	window := SystemWindow new.
	window handleMouseEnter: (self simulatedMouseEventFor: window).
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterWindowRecord.
	self assert: record windowId equals: window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {window})
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseLeaveWindow [
	
	|window|
	self should: [SystemWindow >> #handleMouseLeave: ] raise: KeyNotFound.
	instrumenter instrumentMouseLeaveWindow.
	methodToRemove := (SystemWindow >> #handleMouseLeave:).
	
	window := SystemWindow new.
	window handleMouseLeave: (self simulatedMouseEventFor: window).
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseLeaveWindowRecord.
	self assert: record windowId equals: window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {window})
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentRubScrollTextMorphHandleMouseEnter [
	|morph|

	modifiedClass := RubScrolledTextMorph.
	modifiedMethodSource := (RubScrolledTextMorph >> #mouseEnter:) sourceCode.
	instrumenter instrumentRubScrollTextMorphMouseEnter.
	
	morph := RubScrolledTextMorph new.
	morph mouseEnter: nil.
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterTextEditorRecord.
	self assert: record windowId equals: morph window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {morph})
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentRubScrollTextMorphHandleMouseOver [
	
	self should: [RubScrolledTextMorph >> #handlesMouseOver: ] raise: KeyNotFound.
	instrumenter instrumentRubScrollTextMorphHandleMouseOver.
	methodToRemove := (RubScrolledTextMorph >> #handlesMouseOver:).
		
	self assert: (RubScrolledTextMorph new handlesMouseOver: nil)
]

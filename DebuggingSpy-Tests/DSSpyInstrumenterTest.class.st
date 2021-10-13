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
		'methodToRemove',
		'methodsToRemove'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #assertions }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method [

	self assert: record class equals: DSHaltHitRecord.
	self assert: record method equals: method name.
	self assert: record sourceCodeInterval first equals: method ast statements first start.
	self assert: record sourceCodeInterval last equals: method ast statements first stop
]

{ #category : #assertions }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method conditional: isHaltIf once: isOnce [

	self assert: record conditional equals: isHaltIf.
	self assert: record once equals: isOnce.
	self assertHaltHitRecordingMethod: method
]

{ #category : #assertions }
DSSpyInstrumenterTest >> assertInstrumentDebuggerCommandNamed: debuggerCommandName [

	| cmds cmd |
	modifiedClass := StDebugger class.
	modifiedMethodSource := [ 
	                        (StDebugger class
	                         >> #instrumentCommandsWith:forRoot:)
		                        sourceCode ]
		                        on: Error
		                        do: [ nil ].
	instrumenter instrumentDebuggerCommands.
	debugger := self debuggerOnRecursiveContextForTesting.
	
	cmds := debugger rootCommandsGroup.
	cmd := StDebugger
		       specCommandNamed: debuggerCommandName
		       inGroup: (StDebugger executionCommandGroupIn: cmds) entries.
	(#('Return' 'Proceed') includes: debuggerCommandName) 
		ifTrue:[cmd decoratedCommand forTests: true].
		
	self setDummyWindowForPresenter: debugger.
	
	cmd execute.

	self assertStepActionRecordForCommandNamed: debuggerCommandName
]

{ #category : #assertions }
DSSpyInstrumenterTest >> assertInstrumentSindarinDebuggerCommandNamed: debuggerCommandName [

	| modifiedMethod cmds cmd |
	modifiedClass := StDebugger class.
	modifiedMethod := modifiedClass>>#buildSindarinExtentionCommandsGroupWith:forRoot:.
	modifiedMethodSource := [ modifiedMethod sourceCode ]
		                        on: Error
		                        do: [ nil ].
	instrumenter instrumentSindarinDebuggerCommands.
	debugger := self debuggerOnRecursiveContextForTesting.

	self setDummyWindowForPresenter: debugger.
	
	"Commands from toolbar"
	cmds := debugger rootCommandsGroup
	 / StDebuggerToolbarCommandTreeBuilder groupName
	/ 'Advanced Step'.
	cmd := StDebugger
		       specCommandNamed: debuggerCommandName
		       inGroup: cmds entries.
	
	cmd decoratedCommand forTests: true.
	cmd execute.

	self assertStepActionRecordForCommandNamed: debuggerCommandName.
	
	DSRecordRegistry current reset.
	
	"Commands from code menu"
	cmds := debugger rootCommandsGroup
	             / StDebuggerCodeCommandTreeBuilder groupName
	             / StDebuggerCodeCommandTreeBuilder new codeDebugCommandsGroupName.
	cmd := StDebugger
		       specCommandNamed: debuggerCommandName
		       inGroup: cmds entries.
	cmd decoratedCommand forTests: true.
	cmd execute.

	self assertStepActionRecordForCommandNamed: debuggerCommandName.
]

{ #category : #assertions }
DSSpyInstrumenterTest >> assertStepActionRecordForCommandNamed: debuggerCommandName [

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSStepActionRecord.
	self assert: record eventName equals: debuggerCommandName.
	self assert: record windowId equals: debugger window window hash.
	self
		assert: record context
		equals: debugger currentContext printString.
	self
		assert: record node
		equals: debugger currentContext sourceNodeExecuted printString.
	self assert: record receiver equals: debugger currentContext receiver printString.
	self assert: record receiverClass equals: debugger currentContext receiver class name
]

{ #category : #helpers }
DSSpyInstrumenterTest >> clyTextEditor [

	| editor textArea |
	editor := ClyTextEditor forTextArea:
		          (textArea := RubEditingArea new).	
	textArea setTextWith: '41+1'.		
	textArea releaseEditor.
	textArea editorClass: DSFakeTextEditor.
	textArea editor.	
	editor selectAll.
	^ editor
]

{ #category : #helpers }
DSSpyInstrumenterTest >> codePresenterFrom: aPlaygroundPagePresenter [

	| codePresenter adapter |
	codePresenter := (aPlaygroundPagePresenter class slotNamed: #text) 
		                 read: aPlaygroundPagePresenter.
	self setDummyWindowPresenter: aPlaygroundPagePresenter window forPresenter: codePresenter.
	codePresenter text: '41+1'.
	codePresenter selectionInterval: (1 to: 4).	
	
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: codePresenter.	
	codePresenter adapter: adapter.
	codePresenter adapter buildWidget.
	adapter widget selectionInterval: (1 to: 4).	
	^ codePresenter
]

{ #category : #helpers }
DSSpyInstrumenterTest >> debuggerForTesting [

	debugger := StTestDebuggerProvider new debuggerWithObjectHalting.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	^ debugger
]

{ #category : #helpers }
DSSpyInstrumenterTest >> debuggerForTestingWithWindow [

	debugger := StTestDebuggerProvider new debuggerWithObjectHalting.
	self setDummyWindowForPresenter: debugger.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	^ debugger
]

{ #category : #helpers }
DSSpyInstrumenterTest >> debuggerOnRecursiveContextForTesting [

	^ StTestDebuggerProvider new debuggerWithRecursiveContext
		  application: StDebugger currentApplication;
		  initialize
]

{ #category : #helpers }
DSSpyInstrumenterTest >> debuggerWithRunnableContext [

	^ StTestDebuggerProvider new debuggerWithObjectHalting
		  application: StDebugger currentApplication;
		  initialize
]

{ #category : #helpers }
DSSpyInstrumenterTest >> executeHalt [ 

	<haltOrBreakpointForTesting>
	self halt
]

{ #category : #helpers }
DSSpyInstrumenterTest >> executeHaltIf [

	<haltOrBreakpointForTesting>
	self haltIf: [ true ]
]

{ #category : #helpers }
DSSpyInstrumenterTest >> executeHaltInBloc [
	<haltOrBreakpointForTesting>
	[self halt] value
]

{ #category : #helpers }
DSSpyInstrumenterTest >> executeHaltOnce [
	<haltOrBreakpointForTesting>
	self haltOnce
]

{ #category : #helpers }
DSSpyInstrumenterTest >> executeHaltWithMessage [
	<haltOrBreakpointForTesting>
	self halt: 'message'
]

{ #category : #helpers }
DSSpyInstrumenterTest >> metaPaneClassesItems: listName FromInspector: aMetaPane [

	^ (aMetaPane class slotNamed: listName) read: aMetaPane
]

{ #category : #helpers }
DSSpyInstrumenterTest >> newInspectorOn: anObject [

	| inspector |
	inspector := StInspector basicNew.
	self setDummyWindowForPresenter: inspector.
	inspector setModelBeforeInitialization:
		(StInspectorModel on: anObject).
	inspector initialize.
	^ inspector
]

{ #category : #helpers }
DSSpyInstrumenterTest >> playgroundPagePresenter [

	| playground |
	playground := StPlaygroundPagePresenter basicNew.
	self setDummyWindowForPresenter: playground.
	playground setModelBeforeInitialization: (NewValueHolder value: nil).
	playground application: StPharoApplication current.
	playground initialize.
	^ playground
]

{ #category : #helpers }
DSSpyInstrumenterTest >> press: aCharacter in: aPresenter [

	aPresenter adapter
		keyDown: aCharacter asciiValue
		shift: false
		meta: false
		control: false
		option: false
]

{ #category : #helpers }
DSSpyInstrumenterTest >> recompileExecuteHaltOnce [

	self class compile: 'executeHaltOnce
	<haltOrBreakpointForTesting>
	self haltOnce'
]

{ #category : #helpers }
DSSpyInstrumenterTest >> registry [
	^DSRecordRegistry current records
]

{ #category : #helpers }
DSSpyInstrumenterTest >> rubTextEditor [

	| editor textArea |
	editor := RubSmalltalkEditor forTextArea:
		          (textArea := RubEditingArea new).	
	textArea setTextWith: '41+1' printString.		
	textArea releaseEditor.
	textArea editorClass: DSFakeTextEditor.
	textArea editor.	
	editor selectAll.
	^ editor
]

{ #category : #helpers }
DSSpyInstrumenterTest >> runWithoutOpeningDebugger: aBlock [

	| debuggerSelectionStrategy |
	debuggerSelectionStrategy := OupsDebuggerSelectionStrategy
		                             debuggerSelectionStrategy.
	OupsDebuggerSelectionStrategy debuggerSelectionStrategy:
		DSNoDebuggerSelectionStrategy.

	aBlock
		on: Error
		do: [ :err | 
			OupsDebuggerSelectionStrategy debuggerSelectionStrategy:
				debuggerSelectionStrategy.
			err debug ].
	OupsDebuggerSelectionStrategy debuggerSelectionStrategy:
		debuggerSelectionStrategy
]

{ #category : #helpers }
DSSpyInstrumenterTest >> setDummyWindowForMorph: morph [

	[ morph privateOwner: SystemWindow basicNew ]
		on: Error
		do: [  ]
]

{ #category : #helpers }
DSSpyInstrumenterTest >> setDummyWindowForPresenter: presenter [

	| windowPresenter |
	windowPresenter := SpWindowPresenter new.
	windowPresenter application: StPharoApplication current.
	[windowPresenter window: SystemWindow basicNew] on: Error do:[].
	self setDummyWindowPresenter: windowPresenter forPresenter: presenter

]

{ #category : #helpers }
DSSpyInstrumenterTest >> setDummyWindowPresenter: windowPresenter forPresenter: presenter [

	windowPresenter presenter: presenter
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

{ #category : #helpers }
DSSpyInstrumenterTest >> tableItemsListFromInspector: anInspector [

	| ctxPresenter rawView attrTable widget |
	anInspector buildWithSpec.
	self setDummyWindowForPresenter: anInspector.
	ctxPresenter := anInspector firstPage rawInspectorPageOrNil
		                retrievePresenter.
	rawView := (ctxPresenter class slotNamed: #view) read: ctxPresenter.
	
	self setDummyWindowPresenter: anInspector window forPresenter: rawView.
	attrTable := rawView attributeTable.
	attrTable buildWithSpec.
	self setDummyWindowPresenter: anInspector window forPresenter: attrTable.
	widget := attrTable adapter widget.
	^ widget dataSource rootItem children
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

	methodsToRemove ifNotNil: [ 
		methodsToRemove do: [ :m | m removeFromSystem ] ].
	
	DSRecordRegistry current reset.
	
	super tearDown
]

{ #category : #'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentClyFullBrowser [

	modifiedClass := ClyFullBrowserMorph.
	modifiedMethodSource := (ClyFullBrowserMorph >> #newWindowTitle) sourceCode.
	instrumenter instrumentClyFullBrowser.
	browser := ClyFullBrowserMorph on: ClyNavigationEnvironment currentImage.  
	browser  prepareInitialStateBy:  [ :b |b selectMethod: (Object>>#yourself)].
	self setDummyWindowForMorph: browser.
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
	
	modifiedClass := ClyQueryBrowserMorph.
	modifiedMethodSource := (ClyQueryBrowserMorph >> #newWindowTitle) sourceCode.
	instrumenter instrumentClyQueryBrowser.
	browser := ClyQueryBrowserMorph on: ClyNavigationEnvironment currentImage.  
	browser showResultOf: (ClyMessageImplementorsQuery of: #instrumentClyQueryBrowser).
	self setDummyWindowForMorph: browser.
	browser newWindowTitle.
	
	self assert: self registry size equals: 1.
	
	record := self registry first.
	self assert: record class identicalTo: DSQueryBrowseRecord.
	self assert: record windowId equals: browser window hash.
	self assert: record queryName equals: browser systemQuery description
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorPrintIt [

	| clyEditor |
	modifiedClass := ClyTextEditor.
	modifiedMethodSource := (ClyTextEditor >> #printIt) sourceCode.
	instrumenter instrumentClyTextEditorPrintIt.

	clyEditor := self clyTextEditor.
	clyEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSPrintItRecord.	
	self assert: record selectedString equals: '41+1'
]

{ #category : #'tests - playground' }
DSSpyInstrumenterTest >> testInstrumentCodePresenter [
	|playground code|
	modifiedClass := SpCodePresenter.	
	modifiedMethodSource :=  [(SpCodePresenter >> #initialize) sourceCode] on: Error do:[nil].
	instrumenter instrumentCodePresenter.	
	playground := self playgroundPagePresenter.
	self setDummyWindowForPresenter: playground.
	code := self codePresenterFrom: playground.
	
	"When typing code, the playground generates an writing record"
	self press: $t in: code.
	self assert: self registry size equals: 1.
	record := self registry first.	
	self assert: record class identicalTo: DSPlaygroundWriteRecord.
	self assert: record windowId equals: playground window window hash.
	
	"When the mouse enters the playground, if the playground has focus, generates a reading event"
	code adapter sendMouseEnterEvent.
	self assert: self registry size equals: 2.
	record := self registry second.	
	self assert: record class identicalTo: DSPlaygroundReadRecord.
	self assert: record windowId equals: playground window window hash
	
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerCode [
	|code adapter|
	modifiedClass := SpCodePresenter.	
	modifiedMethodSource :=  [(SpCodePresenter >> #initialize) sourceCode] on: Error do:[nil].
	instrumenter instrumentCodePresenter.	
	
	debugger := self debuggerForTesting.	
	code := debugger code.	
	self setDummyWindowForPresenter: code.
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: code.	
	code adapter: adapter.
	code adapter buildWidget.		

	"When typing code, the playground code a writing record"
	self press: $t in: code.
	self assert: self registry size equals: 1.
	record := self registry first.	
	self assert: record class identicalTo: DSPlaygroundWriteRecord.
	self assert: record windowId equals: code window window hash.
	
	"When the mouse enters the playground, if the playground has focus, generates a reading event"
	code adapter sendMouseEnterEvent.
	self assert: self registry size equals: 2.
	record := self registry second.	
	self assert: record class identicalTo: DSPlaygroundReadRecord.
	self assert: record windowId equals: code window window hash
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerOpening [
	modifiedClass := StDebugger.	
	modifiedMethodSource :=  [(StDebugger >> #initializeWindow:) sourceCode] on: Error do:[nil].
	
	debugger := self debuggerForTestingWithWindow.			
	instrumenter instrumentDebuggerOpening.	
	debugger initializeWindow: debugger window.
	
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSDebuggerOpeningRecord.
	self assert: record windowId equals: debugger window window hash.
	self assert: record debuggerId equals: debugger hash.
	self assert: record contextName equals: debugger currentContext method printString.
	self assert: record sourceNodeClass equals: debugger currentContext  sourceNodeExecuted class name.
	self assert: record sourceNodeCode equals: debugger currentContext  sourceNodeExecuted sourceCode
	
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerStack [
	|selectedItem|
	modifiedClass := StDebugger.
	modifiedMethodSource := (StDebugger >> #initializeStack) sourceCode.
	instrumenter instrumentDebuggerStack.
	
	debugger := self debuggerForTestingWithWindow.		
	self assert: self registry size equals: 2.
	
	"No idea why: the stack seems to be refreshed 2 times at opening.
	This generates two identical events:"
	self assert: self registry first windowId equals: self registry second windowId. 
	self assert: self registry first receiver equals: self registry second receiver.
	self assert: self registry first selector equals: self registry second selector.
	self assert: self registry first contextName equals: self registry second contextName.
	self assert: self registry first sourceNodeClass equals: self registry second sourceNodeClass.
	self assert: self registry first sourceNodeCode equals: self registry second sourceNodeCode.
	
	debugger stackTable selectItem: debugger stackTable items second.
	self assert: self registry size equals: 3.
	
	record := self registry third.
	selectedItem := debugger stackTable items second.
	self assert: record class identicalTo: DSBrowseContextRecord.
	self assert: record windowId equals: debugger window window hash.
	self assert: record contextName equals: selectedItem method printString.
	self assert: record sourceNodeClass equals: selectedItem sourceNodeExecuted class name.
	self assert: record sourceNodeCode equals: selectedItem sourceNodeExecuted sourceCode.
	self assert: record receiver equals: selectedItem receiver printString.
	self assert: record selector equals: selectedItem selector
]

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentExpandAttribute [
	|inspector object items|
	modifiedClass := FTBasicItem.
	modifiedMethodSource := (FTBasicItem >> #expandAndRefresh) sourceCode.
	instrumenter instrumentExpandAttribute.
	
	object := OrderedCollection new.
	inspector := StInspector onObject: object.		
	items := self tableItemsListFromInspector: inspector.	
	items first expandAndRefresh.
	
	self assert: self registry size equals: 1.
	record := self registry first.
		
	self assert: record class identicalTo: DSExpandAttributeRecord.
	self assert: record windowId equals: inspector window window hash.
	self assert: record attributeName equals: 'self'. 	
	self assert: record attributeHash equals: object hash.
	self assert: record attributeValue equals: object displayString 
]

{ #category : #'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHits [

	instrumenter instrumentHaltHits.
	methodsToRemove := { 
		                   (Halt class >> #signal:).
		                   (Halt class >> #signalIn:).
		                   (Halt class >> #signal) }.
	[ self executeHalt ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record selector equals: #halt.
	self assertHaltHitRecordingMethod:  (self class >> #executeHalt) conditional: false once: false.
	
	[ self executeHaltIf ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record selector equals: #haltIf:.
	self assertHaltHitRecordingMethod:  (self class >> #executeHaltIf) conditional: true once: false.
	
	self recompileExecuteHaltOnce.
	[ self executeHaltOnce ]
		on: Halt
		do: [  ].
	self assert: self registry size equals: 3.
	record := self registry third.
	self assert: record selector equals: #once.
	self assertHaltHitRecordingMethod:  (self class >> #executeHaltOnce) conditional: false once: true.	
	
	[ self executeHaltWithMessage  ]
		on: Halt
		do: [  ].
	self assert: self registry size equals: 4.
	record := self registry fourth.
	self assert: record selector equals: #now:.
	self assertHaltHitRecordingMethod:  (self class >> #executeHaltWithMessage) conditional: false once: false.
]

{ #category : #'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHitsInBlock [
	|executedMethod|
	instrumenter instrumentHaltHits.
	methodsToRemove := { 
		                   (Halt class >> #signal:).
		                   (Halt class >> #signalIn:).
		                   (Halt class >> #signal) }.
		
	executedMethod := self class >> #executeHaltInBloc.
	[ self executeHaltInBloc  ]
		on: Halt
		do: [  ].
		
	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record conditional equals: false.
	self assert: record once equals: false.
	self assert: record class equals: DSHaltHitRecord.
	self assert: record method equals: executedMethod name.	
	self assert: record sourceCodeInterval first equals: executedMethod ast statements first receiver statements first start.
	self assert: record sourceCodeInterval last equals: executedMethod ast statements first receiver statements first stop
]

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectMethodsOfClass [
	|metaPane object classes|
	modifiedClass := StMetaBrowser.
	modifiedMethodSource := (StMetaBrowser >> #methodsOf:) sourceCode.
	instrumenter instrumentInspectMethodsOfClass.
	
	object := OrderedCollection new.
	metaPane := StMetaBrowser basicNew.
	self setDummyWindowForPresenter: metaPane.
	metaPane application: StPharoApplication current.
	metaPane setModelBeforeInitialization: object.
	metaPane	initialize.
	classes := self metaPaneClassesItems: #classes FromInspector: metaPane.
		
	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSInspectMethodsRecord.
	self assert: record windowId equals: metaPane window window hash.
	self assert: record selectedClass equals: object class name.
	self assert: record inspectedObject equals: object printString.
	
	classes clickAtPath: { 1. 1. 1. 1}.
	record := self registry second.
	self assert: record selectedClass equals: object class superclass name
]

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectSourceOfMethod [
	|metaPane object methods|
	modifiedClass := StMetaBrowser.
	modifiedMethodSource := (StMetaBrowser >> #updateSourceWith:) sourceCode.
	instrumenter instrumentInspectSourceOfMethod.
	
	object := OrderedCollection new.
	metaPane := StMetaBrowser on: object.
	methods := self metaPaneClassesItems: #methods FromInspector: metaPane.
	
	self setDummyWindowForPresenter: metaPane.
	
	methods selectItem: methods items first.
	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSInspectMethodSourceRecord.
	self assert: record selectedMethod equals: metaPane selectedMethod name.
	
	self assert: record windowId equals: metaPane window window hash.
	self assert: record selectedClass equals: object class name.
	self assert: record inspectedObject equals: object printString
	
	
	
]

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectorOnObject [
	|inspector object|
	modifiedClass := StInspector.
	modifiedMethodSource := (StInspector >> #initializePresenters) sourceCode.
	instrumenter instrumentInspectorOnObject.
	
	object := OrderedCollection new.
	inspector := self newInspectorOn: object.

	self assert: self registry size equals: 1.
	record := self registry first.
	
	
	self assert: record class identicalTo: DSInspectObjectRecord.
	self assert: record windowId equals: inspector window window hash.
	self assert: record inspectedObject equals: object printString.
	self assert: record inspectedObjectHash equals: object hash
]

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectorPageSelection [
	|inspector object objectInspector pagesView|
	modifiedClass := StObjectInspectorPresenter.
	modifiedMethodSource := (StObjectInspectorPresenter >> #initializePresenters) sourceCode.
	instrumenter instrumentInspectorPageSelection.
	
	object := OrderedCollection new.	
	inspector := self newInspectorOn: object.
	objectInspector := inspector firstPage.
	pagesView := (objectInspector class slotNamed: #views) read: objectInspector.	

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSSelectInspectorPageRecord.
	self assert: record windowId equals: inspector window window hash.
	self assert: record pageTitle equals: pagesView pages first title. 	
	self assert: record inspectedObjectHash equals: object hash.
	self assert: record inspectedObject equals: object printString.
	
	pagesView selectPage: pagesView pages second.
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record pageTitle equals: pagesView pages second title	
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

{ #category : #'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentNavigateAttribute [
	|raw object|
	modifiedClass := StRawInspection.
	modifiedMethodSource := (StRawInspection >> #setAttributeTable) sourceCode.
	instrumenter instrumentNavigateAttribute.
	
	object := OrderedCollection new.
	raw := StRawInspection on: object.
	self setDummyWindowForPresenter: raw.	
	raw selectPath: #(2).

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSNavigateAttributeRecord.
	self assert: record windowId equals: raw window window hash.
	self assert: record inspectedObject equals: object printString.
	self assert: record inspectedObjectHash equals: object hash
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentProceed [

	self assertInstrumentDebuggerCommandNamed: 'Proceed'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRestart [

	self assertInstrumentDebuggerCommandNamed: 'Restart'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentReturn [

	self assertInstrumentDebuggerCommandNamed: 'Return'
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorDebugIt [

	| rubEditor |
	self skip.
	modifiedClass := RubSmalltalkEditor.
	modifiedMethodSource := (RubSmalltalkEditor >> #debug:) sourceCode.
	instrumenter instrumentRubEditorDebugIt.
	
	rubEditor := self rubTextEditor.
	rubEditor selectAll.
	self runWithoutOpeningDebugger: [rubEditor debugIt].

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSDebugItRecord.	
	self assert: record selectedString equals: '41+1' printString
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorDoIt [

	| rubEditor |
	modifiedClass := RubSmalltalkEditor.
	modifiedMethodSource := (RubSmalltalkEditor >> #doIt) sourceCode.
	instrumenter instrumentRubEditorDoIt.
	
	rubEditor := self rubTextEditor.
	rubEditor selectAll.
	rubEditor doIt.

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSDoItRecord.	
	self assert: record selectedString equals: '41+1'printString
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorPrintIt [

	| rubEditor |
	modifiedClass := RubSmalltalkEditor.
	modifiedMethodSource := (RubSmalltalkEditor >> #printIt) sourceCode.
	instrumenter instrumentRubEditorPrintIt.

	rubEditor := self rubTextEditor.
	rubEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSPrintItRecord.	
	self assert: record selectedString equals: '41+1'
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentRubScrollTextMorphHandleMouseOver [
	
	self should: [RubScrolledTextMorph >> #handlesMouseOver: ] raise: KeyNotFound.
	instrumenter instrumentRubScrollTextMorphHandleMouseOver.
	methodToRemove := (RubScrolledTextMorph >> #handlesMouseOver:).
		
	self assert: (RubScrolledTextMorph new handlesMouseOver: nil)
]

{ #category : #'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentRubScrollTextMorphMouseEnter [
	|morph|

	modifiedClass := RubScrolledTextMorph.
	instrumenter instrumentRubScrollTextMorphMouseEnter.
	methodToRemove := (RubScrolledTextMorph >> #mouseEnter:).
	morph := RubScrolledTextMorph new.
	morph mouseEnter: nil.
	
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterTextEditorRecord.
	self assert: record windowId equals: morph window hash.
	self assert: record itemElement equals: (DSMouseEventRecord printStringMorphs: {morph})
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRunTo [

	self assertInstrumentDebuggerCommandNamed: 'Run to'
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDebugIt [

	| codePresenter debugItCommand |	
	self skip.
	self flag: 'This test seems to make the CI crash because of a debugger opening?'.
	modifiedClass := SpCodeDebugItCommand.
	modifiedMethodSource := (SpCodeDebugItCommand >> #execute) sourceCode.
	instrumenter instrumentSpCodeDebugIt.

	codePresenter := self codePresenterFrom: self playgroundPagePresenter.

	debugItCommand := SpCodeDebugItCommand new.
	debugItCommand context: codePresenter.
	self runWithoutOpeningDebugger: [	debugItCommand execute].

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDebugItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDoIt [

	| codePresenter printItCommand |
	modifiedClass := SpCodeDoItCommand.
	modifiedMethodSource := (SpCodeDoItCommand >> #execute) sourceCode.
	instrumenter instrumentSpCodeDoIt.

	codePresenter := self codePresenterFrom: self playgroundPagePresenter.

	printItCommand := SpCodeDoItCommand new.
	printItCommand context: codePresenter.
	codePresenter rawSelection: (1 to: 4).
	printItCommand execute.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : #'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodePrintIt [

	| codePresenter printItCommand |
	modifiedClass := SpCodePrintItCommand.
	modifiedMethodSource := (SpCodePrintItCommand >> #execute) sourceCode.
	instrumenter instrumentSpCodePrintIt.

	codePresenter := self codePresenterFrom: self playgroundPagePresenter.
	printItCommand := SpCodePrintItCommand new.
	printItCommand context: codePresenter.
	printItCommand execute.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSPrintItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : #'tests - playground' }
DSSpyInstrumenterTest >> testInstrumentStPlayground [
	|playground|
	modifiedClass := StPlayground.
	modifiedMethodSource :=  (StPlayground class >> #open) sourceCode.
	instrumenter instrumentPlaygroundCode.
	playground := StPlayground open.
	
	"On opening, the playground generates an opening record"
	self assert: self registry size equals: 1.
	record := self registry first.	
	self assert: record class identicalTo: DSPlaygroundOpenedRecord.
	self assert: record windowId equals: playground window window hash
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepInto [

	self assertInstrumentDebuggerCommandNamed: 'Into'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepOver [

	self assertInstrumentDebuggerCommandNamed: 'Over'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepThrough [

	self assertInstrumentDebuggerCommandNamed: 'Through'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToMethodEntry [

	self assertInstrumentSindarinDebuggerCommandNamed: 'To method entry'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextCallInClass [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next call in class'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextCallInObject [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next call in receiver'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextInstanceCreation [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next instance creation'
]

{ #category : #'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToReturnCommand [

	self assertInstrumentSindarinDebuggerCommandNamed: 'To return'
]

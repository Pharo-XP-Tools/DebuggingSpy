Class {
	#name : 'DSSpyInstrumenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'modifiedClass',
		'modifiedMethodSource',
		'instrumenter',
		'record',
		'debugger',
		'browser',
		'methodToRemove',
		'methodsToRemove',
		'recordSourceCode'
	],
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'assertions' }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method [

	self assert: record class equals: DSHaltHitRecord.
	self assert: record method equals: method name.
	self assert: record sourceCodeInterval first equals: method ast statements first start.
	self assert: record sourceCodeInterval last equals: method ast statements first stop
]

{ #category : 'assertions' }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method conditional: isHaltIf once: isOnce [

	self assert: record conditional equals: isHaltIf.
	self assert: record once equals: isOnce.
	self assertHaltHitRecordingMethod: method
]

{ #category : 'assertions' }
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

{ #category : 'assertions' }
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

{ #category : 'assertions' }
DSSpyInstrumenterTest >> assertStepActionRecordForCommandNamed: debuggerCommandName [

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSStepActionRecord.
	self assert: record eventName equals: debuggerCommandName.
	self assert: record windowId equals: debugger window window identityHash.
	self
		assert: record context
		equals: debugger currentContext printString.
	self
		assert: record node
		equals: debugger currentContext sourceNodeExecuted printString.
	self assert: record receiver equals: debugger currentContext receiver printString.
	self assert: record receiverClass equals: debugger currentContext receiver class name
]

{ #category : 'helpers' }
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

{ #category : 'helpers' }
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

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerForTesting [

	debugger := StTestDebuggerProvider new debuggerWithObjectHalting.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	^ debugger
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerForTestingWithWindow [

	debugger := StTestDebuggerProvider new debuggerWithObjectHalting.
	self setDummyWindowForPresenter: debugger.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	^ debugger
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerOnRecursiveContextForTesting [

	^ StTestDebuggerProvider new debuggerWithRecursiveContext
		  application: StDebugger currentApplication;
		  initialize
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerWithRunnableContext [

	^ StTestDebuggerProvider new debuggerWithObjectHalting
		  application: StDebugger currentApplication;
		  initialize
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> execute1Halt [
 1 halt
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> executeHalt [ 

	<haltOrBreakpointForTesting>
	self halt
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> executeHaltIf [

	<haltOrBreakpointForTesting>
	self haltIf: [ true ]
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> executeHaltInBloc [
	<haltOrBreakpointForTesting>
	[self halt] value
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> executeHaltOnce [
	<haltOrBreakpointForTesting>
	self haltOnce
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> executeHaltWithMessage [
	<haltOrBreakpointForTesting>
	self halt: 'message'
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> metaPaneClassesItems: listName FromInspector: aMetaPane [

	^ (aMetaPane class slotNamed: listName) read: aMetaPane
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> methodWithDNU [

	self unknownMessage
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> methodWithException [

	Exception new signal
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> newInspectorOn: anObject [

	| inspector |
	inspector := StInspectorPresenter basicNew.
	self setDummyWindowForPresenter: inspector.
	inspector setModelBeforeInitialization:
		(StInspectorModel on: anObject).
	inspector initialize.
	^ inspector
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> playgroundPagePresenter [

	| playground |
	playground := StPlaygroundPagePresenter basicNew.
	self setDummyWindowForPresenter: playground.
	playground setModelBeforeInitialization:
		(NewValueHolderForTestWithDummyPlaygroundPage value: nil).
	playground application: StPharoApplication current.
	playground initialize.
	^ playground
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> press: aCharacter in: aPresenter [

	aPresenter adapter
		keyDown: aCharacter asciiValue
		shift: false
		meta: false
		control: false
		option: false
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> recompileExecuteHaltOnce [

	self class compile: 'executeHaltOnce
	<haltOrBreakpointForTesting>
	self haltOnce'
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> registry [
	^DSRecordRegistry current records
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> rubTextEditor [

	| editor textArea |
	editor := RubSmalltalkEditor forTextArea:
		          (textArea := RubEditingArea new
			                       beForSmalltalkCode;
			                       yourself).
	textArea setTextWith: '41+1' printString.
	textArea releaseEditor.
	textArea editorClass: DSFakeTextEditor.
	textArea editor.
	editor selectAll.
	^ editor
]

{ #category : 'helpers' }
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

{ #category : 'helpers' }
DSSpyInstrumenterTest >> setDummyWindowForMorph: morph [

	[ morph privateOwner: SystemWindow basicNew ]
		on: Error
		do: [  ]
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> setDummyWindowForPresenter: presenter [

	| windowPresenter |
	windowPresenter := SpWindowPresenter new.
	windowPresenter application: StPharoApplication current.
	[windowPresenter window: SystemWindow basicNew] on: Error do:[].
	self setDummyWindowPresenter: windowPresenter forPresenter: presenter

]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> setDummyWindowPresenter: windowPresenter forPresenter: presenter [

	windowPresenter basicPresenter: presenter
]

{ #category : 'running' }
DSSpyInstrumenterTest >> setUp [
	super setUp.
	
	instrumenter := DSSpyInstrumenter new.
	recordSourceCode := DSSpy recordSourceCode.
	DSSpy recordSourceCode: true.
	DSRecordRegistry current reset
]

{ #category : 'helpers' }
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

{ #category : 'helpers' }
DSSpyInstrumenterTest >> stObjectContextModelMock [

	| model context |
	model := StInspectorModel on: StInspectorMockObject new.
	context := StInspectionContext fromPragma:
		           (StInspectorMockObject >> #inspectionMock1) pragmas first.
	context inspectedObject: model inspectedObject.
	^ StObjectContextModel new
		  inspection: model;
		  inspectedObject: model inspectedObject;
		  context: context;
		  yourself
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> tableItemsListFromInspector: anInspector [

	| ctxPresenter rawView attrTable widget |
	anInspector build.
	self setDummyWindowForPresenter: anInspector.
	ctxPresenter := anInspector firstPage rawInspectorPageOrNil
		                retrievePresenter.
	rawView := (ctxPresenter class slotNamed: #view) read: ctxPresenter.
	
	self setDummyWindowPresenter: anInspector window forPresenter: rawView.
	attrTable := rawView attributeTable.
	attrTable build.
	self setDummyWindowPresenter: anInspector window forPresenter: attrTable.
	widget := attrTable adapter widget.
	^ widget dataSource rootItem children
]

{ #category : 'running' }
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
	
	DSSpy recordSourceCode: recordSourceCode.
	
	DSRecordRegistry current reset.
	
	super tearDown
]

{ #category : 'tests - browsers' }
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

{ #category : 'tests - browsers' }
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

{ #category : 'tests - interactions' }
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

{ #category : 'tests - playground' }
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

{ #category : 'tests - debugger' }
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

{ #category : 'tests - debugger' }
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

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerStack [
	|selectedItem|
	modifiedClass := StDebugger.
	modifiedMethodSource := (StDebugger >> #initializeStack) sourceCode.
	instrumenter instrumentDebuggerStack.
	
	debugger := self debuggerForTestingWithWindow.		
	self assert: self registry size equals: 2.
	
	"No idea why: the stack seems to be refreshed 3 times at opening.
	This generates three identical events:"
	self assert: self registry first windowId equals: self registry second windowId. 
	self assert: self registry first receiver equals: self registry second receiver.
	self assert: self registry first selector equals: self registry second selector.
	self assert: self registry first contextName equals: self registry second contextName.
	self assert: self registry first sourceNodeClass equals: self registry second sourceNodeClass.
	self assert: self registry first sourceNodeCode equals: self registry second sourceNodeCode.
	"self assert: self registry first windowId equals: self registry third windowId. 
	self assert: self registry first receiver equals: self registry third receiver.
	self assert: self registry first selector equals: self registry third selector.
	self assert: self registry first contextName equals: self registry third contextName.
	self assert: self registry first sourceNodeClass equals: self registry third sourceNodeClass.
	self assert: self registry first sourceNodeCode equals: self registry third sourceNodeCode."
	
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

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentExpandAttribute [

	| inspector object items |
	modifiedClass := FTBasicItem.
	modifiedMethodSource := (FTBasicItem >> #expandAndRefresh) sourceCode.
	instrumenter instrumentExpandAttribute.

	object := OrderedCollection new.
	inspector := StInspectorPresenter onObject: object.
	items := self tableItemsListFromInspector: inspector.
	items first expandAndRefresh.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSExpandAttributeRecord.
	self
		assert: record windowId
		equals: inspector window window identityHash.
	self assert: record attributeName equals: 'self'.
	self assert: record attributeHash equals: object identityHash.
	self assert: record attributeValue equals: object displayString
]

{ #category : 'tests - halts' }
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
	
	[ self execute1Halt  ]
		on: Halt
		do: [  ].
	self assert: self registry size equals: 5.
	record := self registry fifth.
	self assert: record selector equals: #halt.
	self assertHaltHitRecordingMethod:  (self class >> #execute1Halt) conditional: false once: false.
]

{ #category : 'tests - halts' }
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

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectMethodsOfClass [

	| metaPane object classes |
	modifiedClass := StMetaBrowserPresenter.
	modifiedMethodSource := (StMetaBrowserPresenter >> #methodsOf:)
		                        sourceCode.
	instrumenter instrumentInspectMethodsOfClass.

	object := OrderedCollection new.
	metaPane := StMetaBrowserPresenter basicNew.
	self setDummyWindowForPresenter: metaPane.
	metaPane application: StPharoApplication current.
	metaPane setModelBeforeInitialization: object.

	metaPane initialize.

	classes := self
		           metaPaneClassesItems: #classes
		           FromInspector: metaPane.
	classes selectPath:
		(Array new: OrderedCollection allSuperclasses size + 1 withAll: 1).

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSInspectMethodsRecord.
	self assert: record windowId equals: metaPane window window hash.
	self assert: record selectedClass equals: object class name.
	self assert: record inspectedObject equals: object printString.

	classes clickAtPath: { 1. 1. 1. 1 }.
	record := self registry second.
	self
		assert: record selectedClass
		equals: object class superclass name
]

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectSourceOfMethod [

	| metaPane object methods classes |
	modifiedClass := StMetaBrowserPresenter.
	modifiedMethodSource := (StMetaBrowserPresenter >> #updateSourceWith:)
		                        sourceCode.
	instrumenter instrumentInspectSourceOfMethod.

	object := OrderedCollection new.
	metaPane := StMetaBrowserPresenter on: object.
	methods := self
		           metaPaneClassesItems: #methods
		           FromInspector: metaPane.
	classes := self
		           metaPaneClassesItems: #classes
		           FromInspector: metaPane.

	self setDummyWindowForPresenter: metaPane.

	classes selectPath:
		(Array new: OrderedCollection allSuperclasses size + 1 withAll: 1).

	methods selectItem: methods items first.
	record := self registry first.

	self assert: record class identicalTo: DSInspectMethodSourceRecord.
	self
		assert: record selectedMethod
		equals: metaPane selectedMethod name.

	self assert: record windowId equals: metaPane window window hash.
	self assert: record selectedClass equals: object class name.
	self assert: record inspectedObject equals: object printString
]

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectorOnObject [
	|inspector object|
	modifiedClass := StInspectorPresenter.
	modifiedMethodSource := (StInspectorPresenter >> #initializePresenters) sourceCode.
	instrumenter instrumentInspectorOnObject.
	
	object := OrderedCollection new.
	inspector := self newInspectorOn: object.

	self assert: self registry size equals: 1.
	record := self registry first.
	
	
	self assert: record class identicalTo: DSInspectObjectRecord.
	self assert: record windowId equals: inspector window window identityHash.
	self assert: record inspectedObject equals: object printString.
	self assert: record inspectedObjectHash equals: object identityHash
]

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentInspectorPageSelection [

	| inspector object objectInspector pagesView |
	modifiedClass := StObjectInspectorPresenter.
	modifiedMethodSource := (StObjectInspectorPresenter
	                         >> #initializePresenters) sourceCode.
	instrumenter instrumentInspectorPageSelection.

	object := OrderedCollection new.
	inspector := self newInspectorOn: object.
	objectInspector := inspector firstPage.
	pagesView := (objectInspector class slotNamed: #views) read:
		             objectInspector.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSSelectInspectorPageRecord.
	self
		assert: record windowId
		equals: inspector window window identityHash.
	self assert: record pageTitle equals: pagesView pages first title.
	self assert: record inspectedObjectHash equals: object identityHash.
	self assert: record inspectedObject equals: object printString.

	pagesView selectPage: pagesView pages second.
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record pageTitle equals: pagesView pages second title
]

{ #category : 'tests - mouse events' }
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

{ #category : 'tests - mouse events' }
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

{ #category : 'tests - mouse events' }
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

{ #category : 'tests - mouse events' }
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

{ #category : 'tests - inspector' }
DSSpyInstrumenterTest >> testInstrumentNavigateAttribute [
	|raw object|
	modifiedClass := StRawInspectionPresenter.
	modifiedMethodSource := (StRawInspectionPresenter >> #setAttributeTable) sourceCode.
	instrumenter instrumentNavigateAttribute.
	
	object := OrderedCollection new.
	raw := StRawInspectionPresenter on: object.
	self setDummyWindowForPresenter: raw.	
	raw selectPath: #(2).

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSNavigateAttributeRecord.
	self assert: record windowId equals: raw window window identityHash.
	self assert: record inspectedObject equals: object printString.
	self assert: record inspectedObjectHash equals: object identityHash
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentProceed [

	self assertInstrumentDebuggerCommandNamed: 'Proceed'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRestart [

	self assertInstrumentDebuggerCommandNamed: 'Restart'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentReturn [

	self assertInstrumentDebuggerCommandNamed: 'Return'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorCopySelection [

	| rubEditor registerClipboardText |
	modifiedClass := RubSmalltalkEditor.
	modifiedMethodSource := (RubSmalltalkEditor >> #doIt) sourceCode.
	instrumenter instrumentRubSmalltalkEditorCopySelection.

	registerClipboardText := DSSpy recordClipboardContent.
	DSSpy recordClipboardContent: true.
	[ 
	rubEditor := self rubTextEditor.
	rubEditor selectAll.
	rubEditor copySelection.

	self
		assert:
		(self registry select: [ :r | r class = DSClipboardCopyRecord ])
			size
		equals: 1.
	record := (self registry select: [ :r | 
		           r class = DSClipboardCopyRecord ]) first.

	self assert: record class identicalTo: DSClipboardCopyRecord.
	self assert: record clipboardText asString  equals: Clipboard clipboardText asString] 
		ensure: [ DSSpy recordClipboardContent: registerClipboardText ]
]

{ #category : 'tests - interactions' }
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

{ #category : 'tests - interactions' }
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

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorPaste [

	| rubEditor registerClipboardText |
	modifiedClass := RubSmalltalkEditor.
	modifiedMethodSource := (RubSmalltalkEditor >> #doIt) sourceCode.
	instrumenter instrumentRubSmalltalkEditorPaste.
	registerClipboardText := DSSpy recordClipboardContent.
	DSSpy recordClipboardContent: true.

	[ 
	rubEditor := self rubTextEditor.
	rubEditor textArea beForSmalltalkCode.

	Clipboard clipboardText: 'copiedText'.
	rubEditor selectAll.
	rubEditor paste.
	"Added the select to be able to run the test in an instrumented image"
	self
		assert:
		(self registry select: [ :r | r class = DSClipboardPasteRecord ])
			size
		equals: 1.
	record := (self registry select: [ :r | 
		           r class = DSClipboardPasteRecord ]) first.

	self assert: record class identicalTo: DSClipboardPasteRecord.
	self assert: record clipboardText equals: 'copiedText' ] ensure: [ 
		DSSpy recordClipboardContent: registerClipboardText ]
]

{ #category : 'tests - interactions' }
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

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentRubScrollTextMorphHandleMouseOver [
	
	self should: [RubScrolledTextMorph >> #handlesMouseOver: ] raise: KeyNotFound.
	instrumenter instrumentRubScrollTextMorphHandleMouseOver.
	methodToRemove := (RubScrolledTextMorph >> #handlesMouseOver:).
		
	self assert: (RubScrolledTextMorph new handlesMouseOver: nil)
]

{ #category : 'tests - mouse events' }
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

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRunTo [

	self assertInstrumentDebuggerCommandNamed: 'Run to'
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentScrollingByDraggingSlider [
	
	|slider|
	modifiedClass := SliderMorph.
	modifiedMethodSource := (SliderMorph >> #dragging:) sourceCode.
	instrumenter instrumentScrollingByDraggingSlider.
	
	slider := SliderMorph new.
	slider privateOwner: SystemWindow new.
	
	slider dragging: true.			
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSStartScrollingEventRecord.
	self assert: record windowId equals: slider window hash.

	slider dragging: false.			
	self assert: self registry size equals: 2.	
	record := self registry second.
	self assert: record class identicalTo: DSStopScrollingEventRecord.
	self assert: record windowId equals: slider window hash.
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentScrollingInScrollPanesEvents [
	
	|pane|
	modifiedClass := GeneralScrollPaneMorph.
	modifiedMethodSource := (GeneralScrollPaneMorph >> #mouseWheel:) sourceCode.
	instrumenter instrumentScrollingInScrollPanesEvents.
	
	pane := GeneralScrollPaneMorph new.
	pane privateOwner: SystemWindow new.
	
	pane mouseWheel: MouseWheelEvent new.			
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSScrollEventRecord.
	self assert: record windowId equals: pane window hash
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentScrollingInTablesEvents [
	
	|table|
	modifiedClass := FTTableMorph.
	modifiedMethodSource := (FTTableMorph >> #mouseWheel:) sourceCode.
	instrumenter instrumentScrollingInTablesEvents.
	
	table := FTTableMorph new.
	table privateOwner: SystemWindow new.
	
	table mouseWheel: MouseWheelEvent new.			
	self assert: self registry size equals: 1.	
	record := self registry first.
	self assert: record class identicalTo: DSScrollEventRecord.
	self assert: record windowId equals: table window hash
]

{ #category : 'tests - interactions' }
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

{ #category : 'tests - interactions' }
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

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDoItAndGoForInspector [

	| presenter |
	modifiedClass := StObjectContextPresenter.
	modifiedMethodSource := (StObjectContextPresenter >> #doEvaluateAndGo) sourceCode.
	instrumenter instrumentSpCodeDoItAndGoForInspector.

	presenter := StObjectContextPresenter basicNew.
	presenter setModelBeforeInitialization: self stObjectContextModelMock.
	[presenter intializePresentersWithEvaluator] on: Error do:["we just pass layout initialization errors as we do not care"].
	presenter evaluator text: '4+2'.
	presenter evaluator  selectionInterval: (1 to: 3).
	
	presenter doEvaluateAndGo.	
	
	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItAndGoRecord.
	self assert: record selectedString equals: '4+2'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDoItAndGoForPlayground [

	| presenter |
	modifiedClass := StPlaygroundPagePresenter.
	modifiedMethodSource := (StPlaygroundPagePresenter >> #doEvaluateAndGo) sourceCode.
	instrumenter instrumentSpCodeDoItAndGoForPlayground.

	presenter := StPlaygroundPagePresenter basicNew.
	presenter forceDisableLoading.
	presenter application: StPharoApplication new.
	presenter initializePresenters.
	presenter setModelBeforeInitialization: DSFakeTextEditor new.
	presenter text text: '4+2'.
	presenter text selectionInterval: (1 to: 3).

	presenter doEvaluateAndGo.	
	
	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItAndGoRecord.
	self assert: record selectedString equals: '4+2'
]

{ #category : 'tests - interactions' }
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

{ #category : 'tests - playground' }
DSSpyInstrumenterTest >> testInstrumentStPlayground [
	|playground|
	modifiedClass := StPlaygroundPresenter class.
	modifiedMethodSource :=  (StPlaygroundPresenter class >> #open) sourceCode.
	instrumenter instrumentPlaygroundCode.
	playground := StPlaygroundPresenter open.
	
	"On opening, the playground generates an opening record"
	self assert: self registry size equals: 1.
	record := self registry first.	
	self assert: record class identicalTo: DSPlaygroundOpenedRecord.
	self assert: record windowId equals: playground window window hash
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepInto [

	self assertInstrumentDebuggerCommandNamed: 'Into'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepOver [

	self assertInstrumentDebuggerCommandNamed: 'Over'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepThrough [

	self assertInstrumentDebuggerCommandNamed: 'Through'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToMethodEntry [

	self assertInstrumentSindarinDebuggerCommandNamed: 'To method entry'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextCallInClass [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next call in class'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextCallInObject [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next call in receiver'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextInstanceCreation [

	self assertInstrumentSindarinDebuggerCommandNamed: 'Next instance creation'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToReturnCommand [

	self assertInstrumentSindarinDebuggerCommandNamed: 'To return'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testLoggingInteractionsWithNoSourceCode [
	DSSpy recordSourceCode: false.
	{ 
		DSDebugItRecord.
		DSDoItRecord.
		DSPrintItRecord } do: [ :recordClass | 
		record := recordClass new record: 'test'.
		self
			assert: record selectedString
			equals: DSSpy recordSourceCodeDisabledErrorMessage ]
]

{ #category : #'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordDNU [
	|capturedDNU|
	
	modifiedClass := Exception.
	modifiedMethodSource := (Exception >> #raiseUnhandledError) sourceCode.
	instrumenter instrumentExceptionSignalling.
	
	[self methodWithDNU] on: MessageNotUnderstood do:[:dnu| capturedDNU := dnu. [dnu raiseUnhandledError] on: UnhandledError do:[] ].
		
	record := self registry first.
	self assert: record class equals: DSUnhandledExceptionRecord.
	self assert: record exceptionClass equals: MessageNotUnderstood name.
	self assert: record errorString equals: capturedDNU description.
	self assert: record receiver equals: self class name.
	self assert: record node equals: (self class>>#methodWithDNU) ast children first sourceCode.
	self assert: record method equals: (self class>>#methodWithDNU) selector	
]

{ #category : #'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordException [
	|capturedException|
	
	modifiedClass := Exception.
	modifiedMethodSource := (Exception >> #raiseUnhandledError) sourceCode.
	instrumenter instrumentExceptionSignalling.
		
	[self methodWithException] on: Exception do:[:e| capturedException := e copy. [e raiseUnhandledError] on: UnhandledError do:[] ].

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSUnhandledExceptionRecord.
	self assert: record exceptionClass equals: Exception name.
	self assert: record errorString equals: capturedException description.
	self assert: record receiver equals: self class name.
	self assert: record node equals: (self class>>#methodWithException) ast children first sourceCode.
	self assert: record method equals: (self class>>#methodWithException) selector	
]

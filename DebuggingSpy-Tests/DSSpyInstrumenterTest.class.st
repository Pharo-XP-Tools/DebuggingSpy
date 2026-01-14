Class {
	#name : 'DSSpyInstrumenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'instrumenter',
		'record',
		'debugger',
		'browser',
		'recordSourceCode',
		'intialWindows'
	],
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
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

	| cmds cmd |
	
	debugger := self debuggerOnRecursiveContextForTesting.

	self setDummyWindowForPresenter: debugger.
	
	"Commands from toolbar"
	cmds := debugger rootCommandsGroup
	 / StDebuggerToolbarCommandTreeBuilder groupName
	/ 'Advanced'.
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

{ #category : 'running' }
DSSpyInstrumenterTest >> closeOpenedWindows [

	| currentWindows windowsToClose |
	currentWindows := self currentWorld windowsSatisfying: [ :window | window isInWorld ].
	windowsToClose := currentWindows reject: [ :window | intialWindows includes: window ].
	windowsToClose collect: [ :window | window close ]
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
DSSpyInstrumenterTest >> rubSmalltalkEditor [

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
	
	DSSpyInstrumenter instrumentSystem.
	recordSourceCode := DSSpy recordSourceCode.
	DSSpy recordSourceCode: true.
	DSRecordRegistry current reset.
	intialWindows := self currentWorld windowsSatisfying: [ :window | window isInWorld ]
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
		           (StInspectorMockObject >> #inspectionMock1:) pragmas first.
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

	self closeOpenedWindows.

	DSSpy recordSourceCode: recordSourceCode.
	DSRecordRegistry current reset.

	DSSpyInstrumenter stopInstrumentation.

	super tearDown
]

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentBrowseAction [

	browser := ClyFullBrowserMorph on: ClyNavigationEnvironment currentImage.
	browser prepareInitialStateBy: [ :b | b selectMethod: Object >> #yourself ].
	self setDummyWindowForMorph: browser.
	browser newWindowTitle.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSBrowseRecord.
	self assert: record windowId equals: nil identityHash "At this stage, the window browser is not built"
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorPrintIt [

	| clyEditor |

	clyEditor := self clyTextEditor.
	clyEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSPrintItRecord.	
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerOpening [
	
	debugger := self debuggerForTestingWithWindow.			
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

{ #category : 'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHits [

	[ self executeHalt ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record selector equals: #halt.
	self
		assertHaltHitRecordingMethod: self class >> #executeHalt
		conditional: false
		once: false.

	[ self executeHaltIf ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record selector equals: #haltIf:.
	self
		assertHaltHitRecordingMethod: self class >> #executeHaltIf
		conditional: true
		once: false.

	self recompileExecuteHaltOnce.
	[ self executeHaltOnce ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 5.
	record := self registry at: 5.
	self assert: record selector equals: #once:.
	self
		assertHaltHitRecordingMethod: self class >> #executeHaltOnce
		conditional: false
		once: true.

	[ self executeHaltWithMessage ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 6.
	record := self registry at: 6.
	self assert: record selector equals: #now:.
	self
		assertHaltHitRecordingMethod: self class >> #executeHaltWithMessage
		conditional: false
		once: false.

	[ self execute1Halt ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 7.
	record := self registry at: 7.
	self assert: record selector equals: #halt.
	self
		assertHaltHitRecordingMethod: self class >> #execute1Halt
		conditional: false
		once: false
]

{ #category : 'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHitsInBlock [
	|executedMethod|
		
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

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentImplementorsAction [

	| rubEditor |
	rubEditor := self rubSmalltalkEditor.
	rubEditor sendersOf: #testInstrumentHaltHits.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSImplementorsRecord.
	self assert: record windowId equals: rubEditor hash
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseEnterWindow [

	| window |
	window := SystemWindow new.
	window handleMouseEnter: (self simulatedMouseEventFor: window).

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterWindowRecord.
	self assert: record windowId equals: window hash
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseLeaveWindow [

	| window |
	window := SystemWindow new.
	window handleMouseLeave: (self simulatedMouseEventFor: window).

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSMouseLeaveWindowRecord.
	self assert: record windowId equals: window hash
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

	registerClipboardText := DSSpy recordClipboardContent.
	DSSpy recordClipboardContent: true.
	[ 
	rubEditor := self rubSmalltalkEditor.
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
	
	rubEditor := self rubSmalltalkEditor.
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
	
	rubEditor := self rubSmalltalkEditor.
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
	registerClipboardText := DSSpy recordClipboardContent.
	DSSpy recordClipboardContent: true.

	[
		rubEditor := self rubSmalltalkEditor.
		rubEditor textArea beForSmalltalkCode.

		Clipboard clipboardText: 'copiedText'.
		rubEditor selectAll.
		rubEditor paste. "Added the select to be able to run the test in an instrumented image"
		self assert: (self registry select: [ :r | r class = DSClipboardPasteRecord ]) size equals: 1.
		record := (self registry select: [ :r | r class = DSClipboardPasteRecord ]) first.

		self assert: record class identicalTo: DSClipboardPasteRecord.
		self assert: record clipboardText equals: 'copiedText' ] ensure: [ DSSpy recordClipboardContent: registerClipboardText ]
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorPrintIt [

	| rubEditor |

	rubEditor := self rubSmalltalkEditor.
	rubEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.	
	
	self assert: record class identicalTo: DSPrintItRecord.	
	self assert: record selectedString equals: '''41+1'''
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRunTo [

	self assertInstrumentDebuggerCommandNamed: 'Run to'
]

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentSendersAction [
	
	| rubEditor |
	rubEditor := self rubSmalltalkEditor.
	rubEditor implementorsOf: #testInstrumentHaltHits.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSImplementorsRecord.
	self assert: record windowId equals: rubEditor hash
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDebugIt [

	| codePresenter debugItCommand |	
		
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

	codePresenter := self codePresenterFrom: self playgroundPagePresenter.
	printItCommand := SpCodePrintItCommand new.
	printItCommand context: codePresenter.
	printItCommand execute.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSPrintItRecord.
	self assert: record selectedString equals: '41+1'
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

	self assertInstrumentSindarinDebuggerCommandNamed: 'To next execution in class'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextCallInObject [

	self assertInstrumentSindarinDebuggerCommandNamed: 'To next execution in receiver'
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

{ #category : 'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordDNU [
	|capturedDNU|
	
	[self methodWithDNU] on: MessageNotUnderstood do:[:dnu| capturedDNU := dnu. [dnu raiseUnhandledError] on: UnhandledError do:[] ].
		
	record := self registry first.
	self assert: record class equals: DSUnhandledExceptionRecord.
	self assert: record exceptionClass equals: MessageNotUnderstood name.
	self assert: record errorString equals: capturedDNU description.
	self assert: record receiver equals: self class name.
	self assert: record node equals: (self class>>#methodWithDNU) ast children first sourceCode.
	self assert: record method equals: (self class>>#methodWithDNU) selector	
]

{ #category : 'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordException [
	|capturedException|
		
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

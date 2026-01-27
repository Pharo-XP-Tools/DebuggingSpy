Class {
	#name : 'DSSpyInstrumenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'recordSourceCode',
		'intialWindows'
	],
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'assertions' }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method conditional: isHaltIf once: isOnce forRecord: aRecord [

	self assert: aRecord conditional equals: isHaltIf.
	self assert: aRecord once equals: isOnce.
	self assertHaltHitRecordingMethod: method forRecord: aRecord
]

{ #category : 'assertions' }
DSSpyInstrumenterTest >> assertHaltHitRecordingMethod: method forRecord: aRecord [

	self assert: aRecord class equals: DSHaltHitRecord.
	self assert: aRecord method equals: method name.
	self assert: aRecord sourceCodeInterval first equals: method ast statements first start.
	self assert: aRecord sourceCodeInterval last equals: method ast statements first stop
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
DSSpyInstrumenterTest >> codePresenterFrom: aPlaygroundPagePresenter withText: aText [

	| codePresenter adapter |
	codePresenter := (aPlaygroundPagePresenter class slotNamed: #text) 
		                 read: aPlaygroundPagePresenter.
	self setDummyWindowPresenter: aPlaygroundPagePresenter window forPresenter: codePresenter.
	codePresenter text: aText.
	
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: codePresenter.	
	codePresenter adapter: adapter.
	codePresenter adapter buildWidget.
	^ codePresenter
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerForTesting [

	| debugger |
	debugger := StTestDebuggerProvider new debuggerWithObjectHalting.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	^ debugger
]

{ #category : 'helpers' }
DSSpyInstrumenterTest >> debuggerForTestingWithWindow [

	| debugger |
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
DSSpyInstrumenterTest >> getSindarinDebuggerForTesting [

	| sindarinDebugger dummyActionModel |
	sindarinDebugger := SindarinTestCommandDebugger new.
	dummyActionModel := (StTestDebuggerProvider new debuggerWithContext:
		                     [ SindarinTestObjectToVisit new createInstanceWithNew ] asContext) debuggerClientModel.
	sindarinDebugger session: dummyActionModel session.
	dummyActionModel clear.

	^ sindarinDebugger
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
	DSSpy testingSession: true.
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

	DSSpy recordSourceCode: recordSourceCode.
	DSRecordRegistry current reset.
	DSSpyInstrumenter stopInstrumentation.
	DSSpy resetSpy.
	self closeOpenedWindows.

	'tests' asFileReference ensureDeleteAll.
	super tearDown
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorDebugIt [

	| clyEditor record|
	
	self runWithoutOpeningDebugger: [clyEditor := self clyTextEditor. clyEditor debugIt].

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDebugItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorDoIt [

	| clyEditor record |
	clyEditor := self clyTextEditor.
	clyEditor doIt.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorInspectIt [

	| clyEditor record |
	clyEditor := self clyTextEditor.
	clyEditor inspectIt.

	self assert: self registry size equals: 2.
	record := self registry first.

	self assert: record class identicalTo: DSInspectItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentClyTextEditorPrintIt [

	| clyEditor record |
	clyEditor := self clyTextEditor.
	clyEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSPrintItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentDebuggerOpening [

	| debugger record |
	debugger := self debuggerForTestingWithWindow.
	debugger initializeWindow: debugger window.
	debugger open.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSHaltHitRecord.

	record := self registry second.
	self assert: record class identicalTo: DSWindowOpenedRecord.
	self assert: record windowId equals: debugger window window hash
]

{ #category : 'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHits [

	| record |
	[ self executeHalt ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record selector equals: #halt.
	self
		assertHaltHitRecordingMethod: self class >> #executeHalt
		conditional: false
		once: false
		forRecord: record.

	[ self executeHaltIf ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record selector equals: #haltIf:.
	self
		assertHaltHitRecordingMethod: self class >> #executeHaltIf
		conditional: true
		once: false
		forRecord: record.

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
		once: true
		forRecord: record.

	[ self executeHaltWithMessage ]
		on: Halt
		do: [ ].
	self assert: self registry size equals: 6.
	record := self registry at: 6.
	self assert: record selector equals: #now:.
	self
		assertHaltHitRecordingMethod: self class >> #executeHaltWithMessage
		conditional: false
		once: false
		forRecord: record.

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
		forRecord: record
]

{ #category : 'tests - halts' }
DSSpyInstrumenterTest >> testInstrumentHaltHitsInBlock [

	| executedMethod record |
	executedMethod := self class >> #executeHaltInBloc.
	[ self executeHaltInBloc ]
		on: Halt
		do: [ ].

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record conditional equals: false.
	self assert: record once equals: false.
	self assert: record class equals: DSHaltHitRecord.
	self assert: record method equals: executedMethod name.
	self assert: record sourceCodeInterval first equals: executedMethod ast statements first receiver statements first start.
	self assert: record sourceCodeInterval last equals: executedMethod ast statements first receiver statements first stop
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseEnterWindow [

	| window record |
	window := SystemWindow new.
	window handleMouseEnter: (self simulatedMouseEventFor: window).

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSMouseEnterWindowRecord.
	self assert: record windowId equals: window hash
]

{ #category : 'tests - mouse events' }
DSSpyInstrumenterTest >> testInstrumentMouseLeaveWindow [

	| window record |
	window := SystemWindow new.
	window handleMouseLeave: (self simulatedMouseEventFor: window).

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSMouseLeaveWindowRecord.
	self assert: record windowId equals: window hash
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentProceed [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StProceedCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSProceedRecord
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRestart [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StRestartCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSRestartRecord
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentReturn [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StReturnValueCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSReturnValue
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorCopySelection [

	| rubEditor registerClipboardText record |
	registerClipboardText := DSSpy recordClipboardContent.
	DSSpy recordClipboardContent: true.
	[
		rubEditor := self rubSmalltalkEditor.
		rubEditor selectAll.
		rubEditor copySelection.

		self assert: (self registry select: [ :r | r class = DSClipboardCopyRecord ]) size equals: 1.
		record := (self registry select: [ :r | r class = DSClipboardCopyRecord ]) first.

		self assert: record class identicalTo: DSClipboardCopyRecord.
		self assert: record clipboardText asString equals: Clipboard clipboardText asString ] ensure: [
		DSSpy recordClipboardContent: registerClipboardText ]
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorDebugIt [

	| rubEditor record |
	rubEditor := self rubSmalltalkEditor.
	rubEditor selectAll.
	self runWithoutOpeningDebugger: [ rubEditor debugIt ].

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDebugItRecord.
	self assert: record selectedString equals: '41+1' printString
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorDoIt [

	| rubEditor record |
	rubEditor := self rubSmalltalkEditor.
	rubEditor selectAll.
	rubEditor doIt.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItRecord.
	self assert: record selectedString equals: '41+1' printString
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorInspectIt [

	| rubEditor record |
	rubEditor := self rubSmalltalkEditor.
	rubEditor selectAll.
	rubEditor inspectIt.

	self assert: self registry size equals: 2.
	record := self registry first.

	self assert: record class identicalTo: DSInspectItRecord.
	self assert: record selectedString equals: '41+1' printString
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentRubEditorPaste [

	| rubEditor registerClipboardText record |
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

	| rubEditor record |
	rubEditor := self rubSmalltalkEditor.
	rubEditor printIt.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSPrintItRecord.
	self assert: record selectedString equals: '''41+1'''
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentRunTo [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StRunToSelectionCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSRunToSelectionRecord
]

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentSendersAction [

	| rubEditor record |
	rubEditor := self rubSmalltalkEditor.
	rubEditor sendersOf: #testInstrumentHaltHits.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSImplementorsRecord.
	self assert: record windowId equals: nil
]

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentSpCodeBrowse [

	| codePresenter browseCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter.

	browseCommand := SpBrowseClassCommand new.
	browseCommand context: codePresenter.
	codePresenter rawSelection: (1 to: 4).
	browseCommand execute.

	self assert: self registry size equals: 2.
	record := self registry first.

	self assert: record class identicalTo: DSBrowseRecord.
	self assert: record windowId equals: codePresenter window identityHash
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDebugIt [

	| codePresenter debugItCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter.

	debugItCommand := SpCodeDebugItCommand new.
	debugItCommand context: codePresenter.
	self runWithoutOpeningDebugger: [ debugItCommand execute ].

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDebugItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDoIt [

	| codePresenter printItCommand record |

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

	| presenter record |
	presenter := StObjectContextPresenter basicNew.
	presenter setModelBeforeInitialization: self stObjectContextModelMock.
	[ presenter intializePresentersWithEvaluator ]
		on: Error
		do: [ "we just pass layout initialization errors as we do not care" ].
	presenter evaluator text: '4+2'.
	presenter evaluator selectionInterval: (1 to: 3).

	presenter doEvaluateAndGo.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSDoItAndGoRecord.
	self assert: record selectedString equals: '4+2'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeDoItAndGoForPlayground [

	| presenter record |
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

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentSpCodeImplementors [

	| codePresenter browseCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter withText: 'execute'.

	browseCommand := SpBrowseImplementorsCommand new.
	browseCommand context: codePresenter.
	codePresenter selectionInterval: (1 to: 7).
	browseCommand execute.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSImplementorsRecord.
	self assert: record windowId equals: codePresenter window identityHash.

	record := self registry second.
	self assert: record class identicalTo: DSWindowOpenedRecord
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodeInspectIt [

	| codePresenter inspectItCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter.

	inspectItCommand := SpCodeInspectItCommand new.
	inspectItCommand context: codePresenter.
	codePresenter rawSelection: (1 to: 4).
	inspectItCommand execute.

	self assert: self registry size equals: 2.
	record := self registry first.

	self assert: record class identicalTo: DSInspectItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testInstrumentSpCodePrintIt [

	| codePresenter printItCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter.
	printItCommand := SpCodePrintItCommand new.
	printItCommand context: codePresenter.
	printItCommand execute.

	self assert: self registry size equals: 1.
	record := self registry first.

	self assert: record class identicalTo: DSPrintItRecord.
	self assert: record selectedString equals: '41+1'
]

{ #category : 'tests - browsers' }
DSSpyInstrumenterTest >> testInstrumentSpCodeSenders [

	| codePresenter browseCommand record |
	codePresenter := self codePresenterFrom: self playgroundPagePresenter withText: 'execute'.

	browseCommand := SpBrowseSendersCommand new.
	browseCommand context: codePresenter.
	codePresenter selectionInterval: (1 to: 7).
	browseCommand execute.

	self assert: self registry size equals: 2.

	record := self registry first.
	self assert: record class identicalTo: DSSendersRecord.
	self assert: record windowId equals: codePresenter window identityHash.

	record := self registry second.
	self assert: record class identicalTo: DSWindowOpenedRecord
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepInto [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StStepIntoCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSStepIntoRecord 
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepOver [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StStepOverCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSStepOverRecord
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepThrough [

	| debugger command record |
	debugger := StDummyDebuggerPresenter new.
	command := StStepThroughCommand forContext: debugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSStepThroughRecord
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToMethodEntry [

	| sindarinDebugger command record |
	sindarinDebugger := self getSindarinDebuggerForTesting.
	command := SindarinStepToMethodEntryCommand forContext: sindarinDebugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSSindarinStepToMethodEntry
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextExecutionInClass [

	| sindarinDebugger command record |
	sindarinDebugger := self getSindarinDebuggerForTesting.
	command := SindarinStepToNextExecutionInClassCommand forContext: sindarinDebugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSSindarinStepToNextExecution
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextExecutionInObject [

	| sindarinDebugger command record |
	sindarinDebugger := self getSindarinDebuggerForTesting.
	command := SindarinStepToNextExecutionInObjectCommand forContext: sindarinDebugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSSindarinStepToNextExecution
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToNextInstanceCreation [

	| sindarinDebugger command record |
	sindarinDebugger := self getSindarinDebuggerForTesting.
	command := SindarinStepToNextInstanceCreation forContext: sindarinDebugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSSindarinStepToNextInstanceCreation
]

{ #category : 'tests - debugger' }
DSSpyInstrumenterTest >> testInstrumentStepToReturnCommand [

	| sindarinDebugger command record |
	sindarinDebugger := self getSindarinDebuggerForTesting.
	command := SindarinStepToReturnCommand forContext: sindarinDebugger.
	command execute.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assert: record class identicalTo: DSSindarinStepToReturn
]

{ #category : 'tests - interactions' }
DSSpyInstrumenterTest >> testLoggingInteractionsWithNoSourceCode [

	DSSpy recordSourceCode: false.
	{
		DSDebugItRecord.
		DSDoItRecord.
		DSPrintItRecord } do: [ :recordClass |
			| record |
			record := recordClass new record: 'test'.
			self assert: record selectedString equals: DSSpy recordSourceCodeDisabledErrorMessage ]
]

{ #category : 'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordDNU [

	| capturedDNU record |
	[ self methodWithDNU ]
		on: MessageNotUnderstood
		do: [ :dnu |
				capturedDNU := dnu.
				[ dnu raiseUnhandledError ]
					on: UnhandledError
					do: [ ] ].

	record := self registry first.
	self assert: record class equals: DSUnhandledExceptionRecord.
	self assert: record exceptionClass equals: MessageNotUnderstood name.
	self assert: record errorString equals: capturedDNU description.
	self assert: record receiver equals: self class name.
	self assert: record node equals: (self class >> #methodWithDNU) ast children first sourceCode.
	self assert: record method equals: (self class >> #methodWithDNU) selector
]

{ #category : 'tests - exceptions' }
DSSpyInstrumenterTest >> testRecordException [

	| capturedException record |
	[ self methodWithException ]
		on: Exception
		do: [ :e |
				capturedException := e copy.
				[ e raiseUnhandledError ]
					on: UnhandledError
					do: [ ] ].

	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSUnhandledExceptionRecord.
	self assert: record exceptionClass equals: Exception name.
	self assert: record errorString equals: capturedException description.
	self assert: record receiver equals: self class name.
	self assert: record node equals: (self class >> #methodWithException) ast children first sourceCode.
	self assert: record method equals: (self class >> #methodWithException) selector
]

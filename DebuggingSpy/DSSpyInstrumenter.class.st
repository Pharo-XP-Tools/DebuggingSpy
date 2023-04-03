"
I instrument the system by adding spying instructions (directly in the code, by meta-programming, or by registering to system-events)
"
Class {
	#name : #DSSpyInstrumenter,
	#superclass : #Object,
	#category : #'DebuggingSpy-Instrumentation'
}

{ #category : #'system instrumentation' }
DSSpyInstrumenter class >> instrumentSystem [
	<script>
	self new instrumentSystem.
	DSRecordRegistry autoSerialize: true
]

{ #category : #browsers }
DSSpyInstrumenter >> instrumentClyFullBrowser [

	ClyFullBrowserMorph compile: 'newWindowTitle
	| newTitle |
	
	packageView selection isEmpty ifTrue: [ ^self systemScope description].	
	
	newTitle := self buildTitleFromSelections.
	self systemScope isCurrentImage ifFalse: [ 
		newTitle := newTitle , '' in '', self systemScope description ].

	[DSFullBrowseRecord for: self] on: Error do: [DSSpy log: #ERROR key: #BROWSE].
	^newTitle'
]

{ #category : #browsers }
DSSpyInstrumenter >> instrumentClyQueryBrowser [

	ClyQueryBrowserMorph compile: 'newWindowTitle
	| title | 
	title := systemQuery description.
	resultView areItemsLoaded 
		ifTrue: [title := title capitalized , '' ['' ,  self itemCount asString, '']'']
		ifFalse: [title := ''Loading: '', title ].
	self systemScope isCurrentImage ifFalse: [ 
		title := title , '' in '', self systemScope description ].
	[DSQueryBrowseRecord for: self] on: Error do: [DSSpy log: #ERROR key: #BROWSE].
	^title'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentClyTextEditorPrintIt [

	ClyTextEditor compile: 'printIt
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."

	| printString |
	[DSPrintItRecord for: self selectionString] on: Error do:[:e| DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	self
		evaluateSelectionAndDo: [ :result | 
			
			printString := [ result asScriptResultStringInCalypso ]
				on: Error
				do: [', '<error in printString: try ''Inspect it'' to debug>' printString,' ].
			self afterSelectionInsertAndSelect: printString ]'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentCodePresenter [

	SpCodePresenter compile: 'initialize 

	super initialize.

	"Use the default menu"
	overrideContextMenu := false.
	
	self withSyntaxHighlight.
	self withLineNumbers.
	
	self registerEventsForStyling.
	self clearInteractionModel.

	self eventHandler
		whenKeyDownDo: [ :event | 
			[ DSPlaygroundWriteRecord for: self ]
				on: Error
				do: [:e| DSSpy log: #ERROR key: #PLAYGROUND_WRITE ] ];
		whenMouseEnterDo: [ :evt |
			[ DSPlaygroundReadRecord for: self.  ]
				on: Error
				do: [ DSSpy log: #ERROR key: #PLAYGROUND_READ ] ]'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerCommands [
	StDebugger class compile:
	'instrumentCommandsWith: stDebuggerInstance forRoot: rootCommandGroup

	<extensionCommands>
	self buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup'
	
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerOpening [

	StDebugger compile: 'initializeWindow: aWindowPresenter
	
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self debuggerActionModel statusStringForContext;
		initialExtent: self initialExtent;
		whenClosedDo: [ self clear ].

	self initializeShortcuts: aWindowPresenter.
		[DSDebuggerOpeningRecord for: self ] on: Error do:[:err| DSSpy log: err key: #DEBUGGER_STACK ]	'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerStack [

	StDebugger compile: 'initializeStack

	stackTable := self newTable.
	stackTable
		addColumn: ((SpImageTableColumn
				  title: ''''
				  evaluated: [ :context | self stackIconForContext: context ])
				 width: 8;
				 sortFunction: nil;
				 yourself);
		addColumn: ((SpStringTableColumn
				  title: ''Class''
				  evaluated: [ :item | self printReceiverClassInContext: item ])
				 sortFunction: nil;
				 yourself);
		addColumn:
			((SpStringTableColumn title: ''Method'' evaluated: [ :item | 
					  | method |
					  method := item method.
					  method isCompiledBlock
						  ifTrue: [ method sourceNode sourceCode ]
						  ifFalse: [ method selector ] ])
				 sortFunction: nil;
				 yourself);
		addColumn:
			((SpStringTableColumn title: ''Package'' evaluated: [ :item | 
					  | package |
					  package := item method package.
					  package ifNil: [ ''-'' ] ifNotNil: [ package name asString ] ])
				 sortFunction: nil;
				 yourself).
	stackTable transmitDo: [ :context | 
		stackTable selection isEmpty ifFalse: [ 
			self updateInspectorFromContext: context.
			self updateCodeFromContext: context.
			self expandStackIfLastItemIsSelected.
			self updateWindowTitle.
			[DSBrowseContextRecord for: { context . [self window window] on: Error do:[0] } ] on: Error do:[:err| DSSpy log: #ERROR key: #DEBUGGER_STACK ] ] ].
	stackHeader := self instantiate: StHeaderBar.
	stackHeader label: ''Stack''.
	stackHeader toolbarActions: (CmCommandGroup new
			 register:
				 ((StDebuggerToggleFilterStackCommand forSpecContext: self) 
					  iconName: #changeSorter);
			 register:
				 (StDebuggerSettingsCommand forSpecWithIconNamed: #configuration);
			 asSpecGroup)'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentExpandAttribute [

	FTBasicItem compile: 'expandAndRefresh
	[DSExpandAttributeRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #INSPECTOR_OBSERVE].
	self expand.
	self refreshTable'
]

{ #category : #breakpoints }
DSSpyInstrumenter >> instrumentHaltHits [
	Halt class compile: 'signalIn: ctx	
		
	self = Halt ifTrue:[
	[|sender|				
		sender := thisContext sender sender sender sender sender sender sender sender sender.
		ctx selector = #once ifFalse:[sender := sender sender].
		DSHaltHitRecord for: {sender sourceNodeExecuted. ctx selector}] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ]].
	super signalIn: ctx'.
	
	Halt class compile: 'signal: s
	self = Halt ifTrue:[	[|sender|		
		sender := thisContext sender sender sender sender sender.
		DSHaltHitRecord for:  {sender sourceNodeExecuted. #now:}] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ]].
	super signal: s'.
	
	Halt class compile: 'signal
		self = Halt ifTrue:[	[|sender| 			
		sender := thisContext sender sender sender sender sender.
		DSHaltHitRecord for:  {sender sourceNodeExecuted. #halt}] 
		on: Error 
		do:[:err| DSSpy log: #ERROR key: #HALT_HIT ]].
	super signal'.
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectMethodsOfClass [

	StMetaBrowser compile: 'methodsOf: aClass

	aClass ifNil: [ ^ #() ].
	[DSInspectMethodsRecord for: {self model. self selectedClass. self window window}] on: Error do:[:e| DSSpy log: #ERROR key: #INSPECTOR_META_CLASS].
	^ aClass methods sorted: #selector ascending
'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectSourceOfMethod [

	StMetaBrowser compile: 'updateSourceWith: method
	source userActionDuring: [
		method
			ifNotNil: [ 
				[DSInspectMethodSourceRecord for: {self model. self selectedClass. self selectedMethod. self window window}] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_METHOD].
				source text: method sourceCode; beForMethod: method  ]
			ifNil: [ 
				source text: ''''; clearInteractionModel ] ]'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectorOnObject [

	StInspector compile: 'initializePresenters
	[ 
	self class == StPlayground ifFalse: [ 
		DSInspectObjectRecord for: { 
				self model inspectedObject.
				([self window window] on: Error do: [ 0 ]) } ] ]
		on: Error
		do: [ DSSpy log: #ERROR key: #INSPECTOR_INSPECT ].	
	millerList := self instantiate: SpMillerPaginatorPresenter.
	millerList millerListPresenter
		spacing: self spacing;
		presenterBlock: [ :aModel | self newInspectorFor: aModel ];
		setRootModel: self model;
		whenColumnsWillChangeDo: [ self keepLastPageSelectedTabName ]'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectorPageSelection [

	StObjectInspectorPresenter compile: 'initializePresenters
	views := self newNotebook.
	header := self instantiate: StHeaderBar.
	self initializeLayout.
	views whenSelectedPageChangedDo: [ :page | 
		[ 
		DSSelectInspectorPageRecord for: { 
				page title.
				self model inspectedObject.
				[self window window] on: Error do:[0] } ]
			on: Error
			do: [ :e | DSSpy log: #ERROR key: #INSPECTOR_META_CLASS ] ]. .
	self refresh'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseDownFTSelectableMorph [

	FTSelectableMorph compile:'mouseDown: evt 
	[DSMouseDownTableItemRecord for: {self allMorphs. self window}] on: Error do:[:e| DSSpy log: #ERROR key: #CLICK_ON_TABLE_ITEM].
	^super mouseDown: evt '
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseEnterFTSelectableMorph [

	FTSelectableMorph compile: 'mouseEnter: evt

	[DSMouseEnterTableItemRecord for: {self allMorphs. self window}] on: Error do:[:e| DSSpy log: #ERROR key: #ENTER_TABLE_ITEM].
	self color: (selectionColor isTransparent ifTrue: [ self mouseOverColor ] ifFalse: [ self mouseOverColor mixed: 0.5 with: selectionColor ])'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseEnterWindow [

	SystemWindow compile: 'handleMouseEnter: anEvent
	
	[DSMouseEnterWindowRecord for:{{self}. self}] on: Error do:[:e| DSSpy log: #ERROR key: #WINDOW_ENTER ]	.
	self submorphsDo: [:m | m unlock].
	^super handleMouseEnter: anEvent'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseLeaveWindow [
	
	SystemWindow compile: 'handleMouseLeave: anEvent
	
	[DSMouseLeaveWindowRecord for:{{self}. self}] on: Error do:[:e| DSSpy log: #ERROR key: #WINDOW_LEAVE ]	.
	^super handleMouseLeave: anEvent'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentNavigateAttribute [

	StRawInspection compile: 'setAttributeTable

	attributeTable
		roots: self inspectorNodes;
		children: [ :node | node children ].

	self outputSelectionPort transmitDo: [ :val | 
		val ifNotNil: [ 
			[ DSNavigateAttributeRecord for: { {val. model}. self window window} ]
				on: Error
				do: [ :err | DSSpy log: #ERROR key: #INSPECTOR_OBSERVE ] ] ]'
]

{ #category : #playground }
DSSpyInstrumenter >> instrumentPlaygroundCode [

	StPlayground class compile: 'open 
	<script>
	|pg|
	pg := self new openWithSpec.
	[DSPlaygroundOpenedRecord for: pg] on: Error do:[:err| DSSpy log: err key: #PLAYGROUND_OPEN ].
	^pg'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentRubEditorDebugIt [

RubSmalltalkEditor compile: 'debug: aStream
	| method receiver context |
	[DSDebugItRecord for: aStream contents] on: Error do:[:e| DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
	(self model respondsTo: #doItReceiver)
		ifTrue: [ receiver := self model doItReceiver.
			context := self model doItContext ]
		ifFalse: [ receiver := context := nil ].
	method := self compile: aStream for: receiver in: context.
	method isReturnSpecial
		ifTrue: [ self inform: ''Nothing to debug, the expression is optimized''.
			^ self ].
	method notNil
		ifTrue: [ self debug: method receiver: receiver in: context ]'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentRubEditorDoIt [

	RubSmalltalkEditor compile: 'doIt
	"Set the context to include pool vars of the model.  Then evaluate."
	[ DSDoItRecord for: self selectionString]
			on: Error
			do: [ :e | 
				DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	^ self evaluateSelection'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentRubEditorPrintIt [

	RubSmalltalkEditor compile: 'printIt
	| printString |

	self
		evaluateSelectionAndDo: [ :result | 
			[DSPrintItRecord for: result 
			] on: Error do:[:e| DSSpy log: #ERROR key: #ACTION_PRINTIT ].
			printString := [ result printString ]
				on: Error
				do: [ ''<error in printString: try ''''Inspect it'''' to debug>'' ].
				
			self afterSelectionInsertAndSelect: printString ]'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentRubScrollTextMorphHandleMouseOver [

	RubScrolledTextMorph compile: 'handlesMouseOver: evt
	^true'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentRubScrollTextMorphMouseEnter [

	RubScrolledTextMorph compile: 'mouseEnter: evt
	[DSMouseEnterTextEditorRecord for: {{self allMorphs}. self window}] on: Error do:[ DSSpy log: #ERROR key: #CODE_FOCUS ].
	^super mouseEnter: evt'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentScrollingByDraggingSlider [
	
Slider compile: 'dragging: aBoolean

	(aBoolean not and: [ dragging ]) ifTrue: [ 
		[ DSStopScrollingEventRecord for: self window ]
			on: Error
			do: [ :e | DSSpy log: #ERROR key: #SCROLL_STOP ] ].
	dragging := aBoolean.
	dragging ifTrue: [ 
		[ DSStartScrollingEventRecord for: self window ]
			on: Error
			do: [ :e | DSSpy log: #ERROR key: #SCROLL_START ] ]'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentScrollingInScrollPanesEvents [
	
	
GeneralScrollPane  compile: 'mouseWheel: event 
	"Handle a mouseWheel event."
	[DSScrollEventRecord for: self window] on: Error do:[:e| DSSpy log: #ERROR key: #SCROLL].
	(self scrollTarget handlesMouseWheel: event)
		ifTrue: [^self scrollTarget mouseWheel: event]. "pass on"
	
	event isUp ifTrue: [ ^ vScrollbar scrollUp: 3 ].
	event isDown ifTrue: [ ^ vScrollbar scrollDown: 3 ].
	event isLeft  ifTrue: [ ^ hScrollbar scrollLeft: 3 ].
	event isRight  ifTrue: [ ^ hScrollbar scrollRight: 3 ].'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentScrollingInTablesEvents [
	FTTableMorph compile:'mouseWheel: event

	"I tried scrolling up/down with a calculated value (check #scrollUpByPageDelta implementor)
	 but the scrollbar proved been more intelligent than me... looks like hardcoded values 
	 work better :/"
	[DSScrollEventRecord for: self window] on: Error do:[:e| DSSpy log: #ERROR key: #SCROLL].
	event isUp ifTrue: [ 
		self verticalScrollBar scrollRestrictedUp: 3.
		^ self
	].
	event isDown ifTrue: [ 
		self verticalScrollBar scrollRestrictedDown: 3.
		^ self
	].
	
	super mouseWheel: event'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentSindarinDebuggerCommands [
	StDebugger class compile:
	'buildSindarinExtentionCommandsGroupWith: stDebuggerInstance forRoot: rootCommandGroup

	<extensionCommands>
	| commands codeGroup toolbarGroup toolbarSindarinGroup |
	commands := { 
		            DSndarinStepToMethodEntryCommand.
		            DSndarinStepToNextCallInClassCommand.
		            DSndarinStepToNextCallInObjectCommand.
		            DSndarinStepToNextInstanceCreation.
		            DSndarinStepToReturnCommand } collect: [ :class | 		         
		            class forSpecContext: stDebuggerInstance ].

	codeGroup := rootCommandGroup
	             / StDebuggerCodeCommandTreeBuilder groupName
	             / StDebuggerCodeCommandTreeBuilder new codeDebugCommandsGroupName.
	commands do: [ :c | codeGroup register: c ].
	
	toolbarGroup := rootCommandGroup / StDebuggerToolbarCommandTreeBuilder groupName.
	toolbarSindarinGroup := CmCommandGroup forSpec
			beToolbarPopoverButton;
			name: ''Advanced Step'';
			icon: (stDebuggerInstance application iconNamed: #smallExpert);
			yourself.
	toolbarGroup register: toolbarSindarinGroup.
	commands do: [ :c | toolbarSindarinGroup register: c ]'
	
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodeDebugIt [

	SpCodeDebugItCommand compile: 'execute

	| selection |
	selection := self selectedTextOrLine.
	selection ifEmpty: [ ^ '''' ].
	[ 
	DSDebugItRecord for:  
			selection ]
		on: Error
		do: [ :e | 
			DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
	self debug: selection readStream'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodeDoIt [

	SpCodeDoItCommand compile: 'execute

	"Treat the current text selection as an expression; evaluate it."

	self evaluateSelectionAndDo: [ :result | 
		[ 
		DSDoItRecord for: self selectedTextOrLine ]
			on: Error
			do: [ :e | 
				DSSpy log: #ERROR key: #ACTION_DOIT ] ]'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodeDoItAndGoForInspector [

	StObjectContextPresenter compile: 'doEvaluateAndGo
	| value |

	[ 
		DSDoItAndGoRecord for: self evaluator selectedTextOrLine ]
			on: Error
			do: [ :e | 
				DSSpy log: #ERROR key: #DOITANDGO ].
	
	activationBlock ifNil: [ ^ self ].

	value := self evaluator 
		evaluate: self evaluator selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | e pass ].
	
	activationBlock value: (StEvaluatedSelectionModel newValue: value)'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodeDoItAndGoForPlayground [

	StPlaygroundPagePresenter compile: 'doEvaluateAndGo
	| value |
	
	[ 
		DSDoItAndGoRecord for: text selectedTextOrLine ]
			on: Error
			do: [ :e | 
				DSSpy log: #ERROR key: #DOITANDGO ].
	
	activationBlock ifNil: [ ^ self ].

	value := text 
		evaluate: text selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | e pass ].
	
	activationBlock value: (StEvaluatedSelectionModel newValue: value)'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodePrintIt [

	SpCodePrintItCommand compile: 'execute
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."

	self evaluateSelectionAndDo: [ :result | 
		[DSPrintItRecord for: self selectedTextOrLine] on: Error do:[:e| DSSpy log: #ERROR key: #ACTION_PRINTIT ].
		self printObject: result ]'
]

{ #category : #system }
DSSpyInstrumenter >> instrumentSystem [
	self instrumentDebuggerOpening.
	self logClyBrowsersOpenings.
	self logCodeInteractions.
	self logDebuggerInteractions.
	self logHaltAndBreakpointEvents.
	self logInspectorInteractions.
	self logMouseEvents.
	self logPlaygroundOpenings.
	self listenToWindowEvents.
	self listenToMethodChanges
]

{ #category : #breakpoints }
DSSpyInstrumenter >> listenToBreakpointChanges [
	SystemAnnouncer uniqueInstance weak when: BreakpointAdded  send: #recordBreakpointEvent: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: BreakpointHit  send: #recordBreakpointEvent: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: BreakpointRemoved  send: #recordBreakpointEvent: to: DSSpy
]

{ #category : #methods }
DSSpyInstrumenter >> listenToMethodChanges [
	SystemAnnouncer uniqueInstance weak when: MethodModified send: #methodChanged: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodRemoved send: #methodRemoved: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodAdded send: #methodAdded: to: DSSpy
]

{ #category : #windows }
DSSpyInstrumenter >> listenToWindowEvents [

	self currentWorld announcer when: WindowOpened send: #logWindowOpened: to: DSSpy.
]

{ #category : #system }
DSSpyInstrumenter >> logClyBrowsersOpenings [
	self instrumentClyQueryBrowser.
	self instrumentClyFullBrowser 
]

{ #category : #system }
DSSpyInstrumenter >> logCodeInteractions [

	self instrumentClyTextEditorPrintIt.
	self instrumentRubEditorDebugIt.
	self instrumentRubEditorDoIt.
	self instrumentRubEditorPrintIt.
	self instrumentSpCodeDebugIt.
	self instrumentSpCodeDoIt.
	self instrumentSpCodePrintIt.
	self instrumentSpCodeDoItAndGoForInspector.
	self instrumentSpCodeDoItAndGoForPlayground
]

{ #category : #system }
DSSpyInstrumenter >> logDebuggerInteractions [

	self instrumentCodePresenter.
	self instrumentDebuggerCommands.
	self instrumentDebuggerStack.
	self instrumentSindarinDebuggerCommands
]

{ #category : #system }
DSSpyInstrumenter >> logHaltAndBreakpointEvents [
	self instrumentHaltHits.
	self listenToBreakpointChanges 
]

{ #category : #system }
DSSpyInstrumenter >> logInspectorInteractions [

	self instrumentExpandAttribute.
	self instrumentInspectMethodsOfClass.
	self instrumentInspectSourceOfMethod.
	self instrumentInspectorOnObject.
	self instrumentInspectorPageSelection.
	self instrumentNavigateAttribute
]

{ #category : #system }
DSSpyInstrumenter >> logMouseEvents [

	self instrumentMouseDownFTSelectableMorph.
	self instrumentMouseEnterFTSelectableMorph.
	self instrumentMouseEnterWindow.
	self instrumentMouseLeaveWindow.
	self instrumentRubScrollTextMorphHandleMouseOver.
	self instrumentRubScrollTextMorphMouseEnter
]

{ #category : #system }
DSSpyInstrumenter >> logPlaygroundOpenings [
	self instrumentPlaygroundCode
]

{ #category : #system }
DSSpyInstrumenter >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy 
]

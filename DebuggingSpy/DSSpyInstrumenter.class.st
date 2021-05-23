"
I instrument the system by adding spying instructions (directly in the code, by meta-programming, or by registering to system-events)
"
Class {
	#name : #DSSpyInstrumenter,
	#superclass : #Object,
	#category : #DebuggingSpy
}

{ #category : #'system instrumentation' }
DSSpyInstrumenter class >> instrumentSystem [
	<script>
	self new instrumentSystem
]

{ #category : #'debugger- actions' }
DSSpyInstrumenter >> debuggerActionClasses [
	^ {StStepIntoCommand.
	StStepOverCommand.
	StStepThroughCommand.
	StReturnValueCommand.
	StRestartCommand.
	StRunToSelectionCommand.
	StProceedCommand} collect:[:c| c defaultName]
]

{ #category : #deprecated }
DSSpyInstrumenter >> instrumentCalypsoBrowsers [
	self deprecated: 'Instrumentation of tabs?'.
	
	self flag: 'this one does not record the tab changing in the query browser'.
	self flag: 'also: there is no record when the user selects a method in the browser, see that later'.
	TabGroupMorph compile: 'updatePageIndex: index
	"Change to the given page index."

	self pageMorph ifNotNil: [:p | self contentMorph removeMorph: p].
	index > 0 ifTrue: [self contentMorph addMorph: (self pages at: index). 			
			[DSSpy log: (self pages at: index) key: #BROWSE] on: Error do: [DSSpy log: #ERROR key: #BROWSE] ].
	self pageMorph ifNotNil: [:pm | pm layoutChanged].
	self adoptPaneColor: self paneColor'
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
	[DSPrintItRecord for: self selectionString] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	self
		evaluateSelectionAndDo: [ :result | 
			
			printString := [ result asScriptResultStringInCalypso ]
				on: Error
				do: [', '<error in printString: try ''Inspect it'' to debug>' printString,' ].
			self afterSelectionInsertAndSelect: printString ]'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentCodePresenter [

	SpCodePresenter compile: 'initializePresenters
	super initializePresenters.
	self eventHandler
		whenKeyDownDo: [ :event | 
			[ DSPlaygroundWriteRecord for: self ]
				on: Error
				do: [:e| self halt. DSSpy log: #ERROR key: #PLAYGROUND_WRITE ] ];
		whenMouseEnterDo: [ :evt | 
			[ DSPlaygroundReadRecord for: self ]
				on: Error
				do: [ DSSpy log: #ERROR key: #PLAYGROUND_READ ] ]'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerCode [
"
	StDebugger compile: 'initializeCode
	self flag: #DBG_IMPROVE.
	
	code := self newCode.
	code whenSubmitDo: [ :text | 
		self
			recompileMethodTo: text string
			inContext: self stackTable selection selectedItem
			notifying: nil.
			[DSSpy log: self currentContext key: #DEBUGGER_CODE_ACCEPT] on: Error do:[ DSSpy log: #ERROR key: #DEBUGGER_CODE_ACCEPT ] ].
	code whenResetDo: [ self updateCodeFromContext ].	
		
	code eventHandler whenKeyDownDo:[:evt| 
		[DSSpy log: self currentContext key: #DEBUGGER_CODE_WRITE] on: Error do:[ DSSpy log: #ERROR key: #DEBUGGER_CODE_WRITE ] ].

	code eventHandler whenMouseEnterDo:[:evt| 
		[DSSpy log: self currentContext key: #DEBUGGER_CODE_READ] on: Error do:[ DSSpy log: #ERROR key: #DEBUGGER_CODE_READ ] ].
				
	codeHeader := self instantiate: StHeaderBar.	
	codeHeader removeStyleFromLabel: ''label.header''.	
	codeHeader applyStyleToLabel: ''label.headerError''.
	codeHeader label: self session name'"
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
		addColumn: ((SpStringTableColumn
				  title: ''Package''
				  evaluated: [ :item | 
					  item method methodClass package name asString ])
				 sortFunction: nil;
				 yourself).
	stackTable transmitDo: [ :context | 
		stackTable selection isEmpty ifFalse: [ 
			self updateInspectorFromContext: context.
			self updateCodeFromContext: context.
			self expandStackIfLastItemIsSelected.
			self updateWindowTitle.
			[DSBrowseContextRecord for: { context . self window } ] on: Error do:[:err| err freeze inspect. DSSpy log: #ERROR key: #DEBUGGER_STACK ]  ] ].
	stackHeader := self instantiate: StHeaderBar.
	stackHeader label: ''Stack'''
]

{ #category : #'debugger- actions' }
DSSpyInstrumenter >> instrumentDebuggingActions [
	self debuggerActionClasses
		do: [ :c | 
			| sourceStream |
			sourceStream := WriteStream on: String new.
			self rewriteSelector: #execute withArguments: #() in: sourceStream.
			self rewriteTempsFrom: (c >> #execute) ast in: sourceStream.
			sourceStream
				<<
					(self
						logString: c defaultName printString
						key: #DEBUGGER_ACTION printString).
			self rewriteSourceFrom: (c >> #execute) ast in: sourceStream.
			c compile: sourceStream contents ]
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentExpandAttribute [

	FTBasicItem compile: 'expandAndRefresh
	[DSExpandAttributeRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #INSPECTOR_OBSERVE].
	self expand.
	self refreshTable'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectMethodsOfClass [

	StMetaBrowser compile: 'methodsOf: aClass

	aClass ifNil: [ ^ #() ].
	[DSInspectMethodsRecord for: {self model. self selectedClass. self window}] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #INSPECTOR_META_CLASS].
	^ aClass methods sorted: #selector ascending
'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectSourceOfMethod [

	StMetaBrowser compile: 'updateSourceWith: method
	source userActionDuring: [
		method
			ifNotNil: [ 
				[DSInspectMethodSourceRecord for: {self model. self selectedClass. self selectedMethod. self window}] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_METHOD].
				source text: method sourceCode; beForMethod: method  ]
			ifNil: [ 
				source text: ''''; clearInteractionModel ] ]'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectorOnObject [

	StInspector compile: 'initializePresenters
	[DSInspectObjectRecord for: {self model inspectedObject. self window}] on: Error do:[DSSpy log: #ERROR key: #INSPECTOR_INSPECT].	
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
		[DSSelectInspectorPageRecord for: {page title. self model inspectedObject. self window}] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #INSPECTOR_META_CLASS ] ] .
	self refresh'
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseDownFTSelectableMorph [

	FTSelectableMorph compile:'mouseDown: evt 
	DSMouseDownTableItemRecord for: {self allMorphs. self window}.
	^super mouseDown: evt '
]

{ #category : #'mouse events' }
DSSpyInstrumenter >> instrumentMouseEnterFTSelectableMorph [

	FTSelectableMorph compile: 'mouseEnter: evt

	DSMouseEnterTableItemRecord for: {self allMorphs. self window}.
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
			[ DSNavigateAttributeRecord for: { {val. model}. self window } ]
				on: Error
				do: [ :err | DSSpy log: #ERROR key: #INSPECTOR_OBSERVE ] ] ]'
]

{ #category : #playground }
DSSpyInstrumenter >> instrumentPlaygroundCode [

	StPlaygroundPagePresenter compile: 'initializePresenters
	self initializeToolbar.
	self initializeStatusbar.

	(text := self newCode)
		interactionModel: StPlaygroundInteractionModel new;
		lineNumbers: self showLineNumbers;
		overridingContextMenu;
		contextMenu: [ (self menuActionsFor: text) asMenuPresenter ];
		contextKeyBindings: (self menuActionsFor: text) asKMCategory;
		whenTextChangedDo: [ :aString | page contents: aString ].
		
	[DSPlaygroundOpenedRecord for: self window] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_OPEN ].
		
	text eventHandler 
		whenKeyUpDo: [ :event | self updateLineNumber];
	whenKeyDownDo: [ :event | self updateLineNumber.		
			[DSPlaygroundWriteRecord for: self] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_WRITE ] ];
		whenMouseUpDo: [ :event | self updateLineNumber ];
		"before taking focus position will be nil, ensure I have the correct one"
		whenFocusReceivedDo: [ self updateLineNumber ];
		whenMouseEnterDo:[:evt| 
			self halt.
		[DSPlaygroundReadRecord for: self] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_READ ] ].
	self updatePresenter'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentRubEditorDebugIt [

RubSmalltalkEditor compile: 'debug: aStream
	| method receiver context |
	[DSDebugItRecord for: aStream contents] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
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
				self halt.
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
			] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #ACTION_PRINTIT ].
			printString := [ result printString ]
				on: Error
				do: [ ''<error in printString: try ''''Inspect it'''' to debug>'' ].
				
			self afterSelectionInsertAndSelect: printString ]'
]

{ #category : #deprecated }
DSSpyInstrumenter >> instrumentRubKeyStrokePrintString [
	self deprecated: 'Not used anymore'.
		
	RubKeystroke compile:'printString
	| location |
	location := [ morph textArea model owner owner ]
		on: Error
		do: [ morph ].
	location class = ClyTextEditor
		ifTrue: [ location := [ morph textArea model interactionModel browser ]
				on: Error
				do: [ morph ] ].
	location class = RubTextEditor
		ifTrue: [ location := [ morph textArea model ]
				on: Error
				do: [ morph ] ].
	^ location printString'
	
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

{ #category : #deprecated }
DSSpyInstrumenter >> instrumentRubScrolledTextMorph [
	self deprecated: 'Not used anymore?'.
	RubScrolledTextMorph compile: 'whenKeystrokeInTextArea: anAnnouncement   
		[DSSpy log: anAnnouncement key: #CODE_WRITE] on: Error do:[ DSSpy log: #ERROR key: #CODE_WRITE ].
		self announcer announce: (anAnnouncement copy morph: self)'.
		
	RubScrolledTextMorph compile: 'whenGotForcus: anAnnouncement
	[DSSpy log: anAnnouncement key: #CODE_FOCUS] on: Error do:[ DSSpy log: #ERROR key: #CODE_FOCUS ].
	self announcer announce: anAnnouncement.
	self changed'
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
			self halt.
			DSSpy log: #ERROR key: #ACTION_PRINTIT ].
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
				self halt.
				DSSpy log: #ERROR key: #ACTION_PRINTIT ] ]'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentSpCodePrintIt [

	SpCodePrintItCommand compile: 'execute
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."

	self evaluateSelectionAndDo: [ :result | 
		[DSPrintItRecord for: self selectedTextOrLine.] on: Error do:[:e| self halt. DSSpy log: #ERROR key: #ACTION_PRINTIT ].
		self printObject: result ]'
]

{ #category : #deprecated }
DSSpyInstrumenter >> instrumentSystemQueries [
	self deprecated: 'That is not used anymore I think'.
	(SystemNavigation allSelectorsInProtocol: '*Tool-Base')
		do: [ :selector | 
			| method ast class sourceStream |
			method := SystemNavigation lookupSelector: selector.
			ast := method ast.
			class := method methodClass.
			sourceStream := WriteStream on: String new.
			self
				rewriteSelector: selector
				withArguments: method argumentNames
				in: sourceStream.
			self rewriteTempsFrom: ast in: sourceStream.
			sourceStream
				<<
					(self
						logArray:
							((OrderedCollection with: selector printString)
								addAll: method argumentNames;
								yourself)
						key: #SYSTEMQUERY printString).
			self rewriteSourceFrom: ast in: sourceStream.
			class compile: sourceStream contents ]
]

{ #category : #helpers }
DSSpyInstrumenter >> instrumentationSourceTemplate [

	^'[DSSpy log: {1} key: {2}] on: Error do:[DSSpy log: #ERROR key: {2}].'
]

{ #category : #breakpoints }
DSSpyInstrumenter >> listenToBreakpointChanges [
	Breakpoint registerObserver: DSSpy
]

{ #category : #breakpoints }
DSSpyInstrumenter >> listenToHaltsChanges [
	StHaltCache compile: 'setNodeCache: haltAndBreakpointNodes forSelector: aSelector
	|nodeSelectors|
	nodeSelectors := haltAndBreakpointNodes collect:[:n| n selector].
	nodeSelectors addFirst: aSelector.
	[DSSpy log: nodeSelectors key: #HALT_MODIFIED] on: Error do:[ DSSpy log: #ERROR key: #HALT_MODIFIED ].	
	methodsWithHalts at: aSelector put: haltAndBreakpointNodes'.
	
	StHaltCache compile: 'uncacheMethod: aMethodSelector
	(methodsWithHalts keys includes: aMethodSelector)
		ifFalse: [ ^ self ].
	methodsWithHalts removeKey: aMethodSelector.
	[DSSpy log: aMethodSelector key: #HALT_REMOVED] on: Error do:[ DSSpy log: #ERROR key: #HALT_REMOVED ].
	self cacheChanged'
]

{ #category : #breakpoints }
DSSpyInstrumenter >> listenToHaltsHits [
	Halt class compile: 'signalIn: ctx	
	self = Halt ifTrue:[
	[|sender log|
		sender := thisContext sender sender sender sender sender sender sender sender sender sender.
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ]].
	super signalIn: ctx'.
	
	Halt class compile: 'signal: s
	self = Halt ifTrue:[	[|sender log|
		sender := thisContext sender sender sender sender sender .
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ]].
	super signal: s'.
	
	Halt class compile: 'signal
		self = Halt ifTrue:[	[|sender log| 
		sender := thisContext sender sender sender sender sender .
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[  DSSpy log: #ERROR key: #HALT_HIT ]].
	super signal'.
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

{ #category : #logging }
DSSpyInstrumenter >> logArray: anArray key: aKey [
	| stream |
	stream := WriteStream on: String new.
	stream << ${.
	anArray
		do: [ :e | 
			stream << e asString.
			stream << $..
			stream space ].
	stream << $}.
	^ self instrumentationSourceTemplate
		format:
			{stream contents.
			aKey}
]

{ #category : #breakpoints }
DSSpyInstrumenter >> logHaltAndBreakpointEvents [
	self listenToHaltsHits.
	self listenToHaltsChanges.
	self listenToBreakpointChanges 
]

{ #category : #logging }
DSSpyInstrumenter >> logString: aString key: aKey [
	^ self instrumentationSourceTemplate
		format:
			{aString.
			aKey}
]

{ #category : #helpers }
DSSpyInstrumenter >> rewriteSelector: aSelector withArguments: args in: sourceStream [
	args isEmpty
		ifTrue: [ sourceStream << aSelector.
			sourceStream cr.
			^ self ].
	aSelector keywords
		with: args
		do: [ :kw :argName | 
			sourceStream << kw asString.
			sourceStream space.
			sourceStream << argName asString.
			sourceStream space ].
	sourceStream cr
]

{ #category : #helpers }
DSSpyInstrumenter >> rewriteSourceFrom: ast in: stream [
	ast statements
		do: [ :stmt | 
			stream cr.
			stream << stmt sourceCode.
			stream << '.' ]
]

{ #category : #helpers }
DSSpyInstrumenter >> rewriteTempsFrom: ast in: stream [
	ast temporaryNames ifEmpty: [ ^ self ].
	stream << $|.
	ast temporaryNames
		do: [ :tempName | 
			stream << tempName.
			stream space ].
	stream << $|
]

{ #category : #methods }
DSSpyInstrumenter >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy 
]

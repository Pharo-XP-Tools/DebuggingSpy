"
I instrument the system by adding spying instructions (directly in the code, by meta-programming, or by registering to system-events)
"
Class {
	#name : 'DSSpyInstrumenter',
	#superclass : 'Object',
	#category : 'DebuggingSpy-Instrumentation',
	#package : 'DebuggingSpy',
	#tag : 'Instrumentation'
}

{ #category : 'system instrumentation' }
DSSpyInstrumenter class >> instrumentSystem [
	<script>
	self new instrumentSystem.
	DSRecordRegistry autoSerialize: true
]

{ #category : 'browsers' }
DSSpyInstrumenter >> instrumentClyQueryBrowser [

	ClyQueryBrowserMorph compile: 'newWindowTitle
	| title | 
	title := systemQuery description.
	resultView areItemsLoaded 
		ifTrue: [title := title capitalized , '' ['' ,  self itemCount asString, '']'']
		ifFalse: [title := ''Loading: '', title ].
	self systemScope isCurrentImage ifFalse: [ 
		title := title , '' in '', self systemScope description ].
	[DSQueryBrowseRecord for: self] on: Error do: [DSSpy log: #ERROR key: #QUERY].
	^title'
]

{ #category : 'debugger' }
DSSpyInstrumenter >> instrumentCodePresenter [

	SpCodePresenter compile: 'initialize 

	super initialize.

	"Use the default menu"
	overrideContextMenu := false.
	
	self withSyntaxHighlight.
	self withSmartCharacters.
	self showLineNumbers.
	self subscribeToSettingsChangesAnnouncements.
	
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

{ #category : 'as yet unclassified' }
DSSpyInstrumenter >> instrumentDebugIt [
	"Instruments different printIt methods"

	RubSmalltalkEditor link: DSDebugItRecord link toAST: (RubSmalltalkEditor >> #debugIt) ast.
	SpCodePrintItCommand link: DSDebugItRecord link toAST: (SpCodeDebugItCommand >> #execute) ast
]

{ #category : 'debugger' }
DSSpyInstrumenter >> instrumentDebuggerCommands [
	StDebugger class compile:
	'instrumentCommandsWith: stDebuggerInstance forRoot: rootCommandGroup

	<extensionCommands>
	self buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup'
	
]

{ #category : 'debugger' }
DSSpyInstrumenter >> instrumentDebuggerStack [

	StDebugger compile: 'initializeStack
stackTable := self newList.
	stackTable
		activateOnDoubleClick;
		whenActivatedDo: [ :selection | self doBrowseClass ].
	stackTable display:[:selection| StContextPrinter printContext: selection].
	stackTable displayColor:[ :context | self stackColorForContext: context ].
	stackTable displayIcon: [ :context| self stackIconForContext: context ].	
	stackTable transmitDo: [ :context |
		stackTable selection isEmpty ifFalse: [
			self updateInspectorFromContext: context.
			self updateCodeFromContext: context.
			self updateExtensionsFromSession: self session.
			self expandStackIfLastItemIsSelected.
			self updateWindowTitle.
			[DSBrowseContextRecord for: { context . [self window window] on: Error do:[0] } ] on: Error do:[:err| DSSpy log: #ERROR key: #DEBUGGER_STACK ] ] ].
	stackHeader := self instantiate: StHeaderBar.
	stackHeader label: ''Stack'''
]

{ #category : 'as yet unclassified' }
DSSpyInstrumenter >> instrumentDoIt [
	"Instruments different printIt methods"

	RubSmalltalkEditor link: DSDoItRecord link toAST: (RubSmalltalkEditor >> #doIt) ast.
	SpCodePrintItCommand link: DSDoItRecord link toAST: (SpCodeDoItCommand >> #execute) ast
]

{ #category : 'debugpoints  ' }
DSSpyInstrumenter >> instrumentExceptionSignalling [

	Exception compile: 'raiseUnhandledError
	"No one has handled this error, but now give them a chance to decide how to debug it.  If none handle this either then open debugger (see UnhandedError>>#defaultAction)"

	self class = Halt ifFalse:[[	DSUnhandledExceptionRecord for:  self] 
		on: Error 
		do:[:err| DSSpy log: #ERROR key: self class name asSymbol ]].
	^ UnhandledError signalForException: self'
]

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentExpandAttribute [

	FTBasicItem compile: 'expandAndRefresh
	[DSExpandAttributeRecord for: self] on: Error do:[:e| DSSpy log: #ERROR key: #INSPECTOR_OBSERVE].
	self dataSource preservingScrollbarPositionDo: [
		self expand.
		self refreshTable ]'
]

{ #category : 'debugpoints  ' }
DSSpyInstrumenter >> instrumentHaltHits [
	Halt class compile: 'signalIn: ctx	
		
	self = Halt ifTrue:[
	[|sender|				
		sender := thisContext sender sender sender sender sender sender sender sender sender.
		ctx selector = #once: ifFalse:[sender := sender sender].
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

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentInspectMethodsOfClass [

	StMetaBrowserPresenter compile: 'methodsOf: aClass

	aClass ifNil: [ ^ #() ].
	[DSInspectMethodsRecord for: {self model. self selectedClass. self window window}] on: Error do:[:e| DSSpy log: #ERROR key: #INSPECTOR_META_CLASS].
	^ aClass methods sorted: #selector ascending
'
]

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentInspectSourceOfMethod [

	StMetaBrowserPresenter compile: 'updateSourceWith: method
	source userActionDuring: [
		method
			ifNotNil: [ 
				[DSInspectMethodSourceRecord for: {self model. self selectedClass. self selectedMethod. self window window}] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_METHOD].
				source text: method sourceCode; beForMethod: method  ]
			ifNil: [ 
				source text: ''''; clearInteractionModel ] ]'
]

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentInspectorOnObject [

	StInspectorPresenter compile: 'initializePresenters
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

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentInspectorPageSelection [

	StObjectInspectorPresenter compile: 'initializePresenters
	views := self newNotebook.
	header := self instantiate: StHeaderBar.
	
	views whenSelectedPageChangedDo: [ :page | 
		[ 
		DSSelectInspectorPageRecord for: { 
				page title.
				self model inspectedObject.
				[self window window] on: Error do:[0] } ]
			on: Error
			do: [ :e | DSSpy log: #ERROR key: #INSPECTOR_META_CLASS ] ]'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentMouseDownFTSelectableMorph [

	FTSelectableMorph compile:'mouseDown: evt 
	[DSMouseDownTableItemRecord for: {self allMorphs. self window}] on: Error do:[:e| DSSpy log: #ERROR key: #CLICK_ON_TABLE_ITEM].
	^super mouseDown: evt '
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentMouseEnterFTSelectableMorph [

	FTSelectableMorph compile: 'mouseEnter: evt

	[DSMouseEnterTableItemRecord for: {self allMorphs. self window}] on: Error do:[:e| DSSpy log: #ERROR key: #ENTER_TABLE_ITEM].
	colorBeforeOver := self color.
	self color: (selectionColor isTransparent
			 ifTrue: [ self mouseOverColor ]
			 ifFalse: [ self mouseOverColor mixed: 0.5 with: selectionColor ])'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentMouseEnterWindow [

	SystemWindow compile: 'handleMouseEnter: anEvent
	
	[DSMouseEnterWindowRecord for:{{self}. self}] on: Error do:[:e| DSSpy log: #ERROR key: #WINDOW_ENTER ].
	^super handleMouseEnter: anEvent'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentMouseLeaveWindow [
	
	SystemWindow compile: 'handleMouseLeave: anEvent
	
	[DSMouseLeaveWindowRecord for:{{self}. self}] on: Error do:[:e| DSSpy log: #ERROR key: #WINDOW_LEAVE ]	.
	^super handleMouseLeave: anEvent'
]

{ #category : 'inspector' }
DSSpyInstrumenter >> instrumentNavigateAttribute [

	StRawInspectionPresenter compile: 'setAttributeTable

	attributeTable children: [ :node | node children ].

	self outputSelectionPort transmitDo: [ :val | 
		val ifNotNil: [ 
			[ DSNavigateAttributeRecord for: { {val. model}. self window window} ]
				on: Error
				do: [ :err | DSSpy log: #ERROR key: #INSPECTOR_OBSERVE ] ] ]'
]

{ #category : 'as yet unclassified' }
DSSpyInstrumenter >> instrumentPrintIt [
	"Instruments different printIt methods"

	RubSmalltalkEditor link: DSPrintItRecord link toAST: (RubSmalltalkEditor >> #printIt) ast.
	ClyTextEditor link: DSPrintItRecord link toAST: (ClyTextEditor >> #printIt) ast.
	SpCodePrintItCommand link: DSPrintItRecord link toAST: (SpCodePrintItCommand >> #execute) ast
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentRubEditorCopySelection [

RubTextEditor compile: 'copySelection
"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
	DSClipboardCopyRecord for: {self selection . self textArea window hash . self class name}.
	self editingState previousInterval: self selectionInterval.
'
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentRubEditorPaste [

	RubTextEditor compile: 'paste
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."

	self replace: self selectionInterval with: self clipboardText and:
		[self selectAt: self pointIndex].
	DSClipboardPasteRecord for: {self clipboardText . self textArea window hash. self class name}.
	'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentRubScrollTextMorphHandleMouseOver [

	RubScrolledTextMorph compile: 'handlesMouseOver: evt
	^true'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentRubScrollTextMorphMouseEnter [

	RubScrolledTextMorph compile: 'mouseEnter: evt
	[DSMouseEnterTextEditorRecord for: {{self allMorphs}. self window}] on: Error do:[ DSSpy log: #ERROR key: #CODE_FOCUS ].
	^super mouseEnter: evt'
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentRubSmalltalkEditorCopySelection [

RubSmalltalkEditor compile: 'copySelection
"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	| node escapingCharacter selection |
	"Research of selected node for eventual nesting of comment or string."
	self lineSelectAndEmptyCheck: [ ^ self ].
	node := self bestNodeInTextArea.
	escapingCharacter := self getEscapeCharacterFromAst: node.

	selection := (escapingCharacter notNil and: [ "The node, if a comment or a string, should entirely contain the selection.
		We convert the node source interval to an open interval to ignore the node delimiters." 
		              node sourceInterval asOpenInterval includesAll:
			              self selectionInterval ])
		             ifTrue: [ 
		             self selection asString unescapeCharacter:
			             escapingCharacter ]
		             ifFalse: [ self selection asString ].
	self clipboardTextPut: selection.
	self editingState previousInterval: self selectionInterval.
	DSClipboardCopyRecord for: { 
			selection.
			self textArea window hash.
			self class name }
'
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentRubSmalltalkEditorPaste [
	
RubSmalltalkEditor compile:'paste
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."
	| node character escapedText |
	"This method is specialized for Pharo code.
	If paste happens in the context of a comment or a string, the pasted contents should be properly escaped."
	
	"Get the AST node corresponding to where we are going to paste.
	If there is a selection, cut it off, because pasting it will over-write it, and get the AST node at the cut position.
	This is specially important when the selection spans multiple scopes (e.g., it starts inside a comment and finished in the middle of another)."
	node := self bestNodeInTextAreaWithoutSelection.

	"The pasted text could be inserted in some context requiring escaping, e.g., a comment, a string.
	If so, get the escaping character, and escape the pasted text before pasting it."
	character := self getEscapeCharacterFromAst: node.
	escapedText := (self shouldEscapeCharacter: character)
		  ifTrue: [ self escapeCharacter: character inString: self clipboardText ]
		  ifFalse: [ self clipboardText ].
	
	self replace: self selectionInterval with: escapedText and:
		[self selectAt: self pointIndex].
	
	DSClipboardPasteRecord for: {escapedText . self textArea window hash . self class name}.'
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentScrollingByDraggingSlider [
	
SliderMorph compile: 'dragging: aBoolean

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

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentScrollingInScrollPanesEvents [
	
	
GeneralScrollPaneMorph  compile: 'mouseWheel: event 
	"Handle a mouseWheel event."
	[DSScrollEventRecord for: self window] on: Error do:[:e| DSSpy log: #ERROR key: #SCROLL].
	(self scrollTarget handlesMouseWheel: event)
		ifTrue: [^self scrollTarget mouseWheel: event]. "pass on"
	
	event isUp ifTrue: [ ^ vScrollbar scrollUp: 3 ].
	event isDown ifTrue: [ ^ vScrollbar scrollDown: 3 ].
	event isLeft  ifTrue: [ ^ hScrollbar scrollLeft: 3 ].
	event isRight  ifTrue: [ ^ hScrollbar scrollRight: 3 ].'
]

{ #category : 'mouse events' }
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

{ #category : 'debugger' }
DSSpyInstrumenter >> instrumentSindarinDebuggerCommands [
	StDebugger class compile:
	'buildSindarinExtentionCommandsGroupWith: stDebuggerInstance forRoot: rootCommandGroup

	<extensionCommands>
	| commands codeGroup toolbarGroup toolbarSindarinGroup |
	commands := { 
		            DSSindarinStepToMethodEntryCommand.
		            DSSindarinStepToNextExecutionInClassCommand.
		            DSSindarinStepToNextExecutionInObjectCommand.
		            DSSindarinStepToNextInstanceCreation.
		            DSSindarinStepToReturnCommand } collect: [ :class | 		         
		            class forSpecContext: stDebuggerInstance ].

	codeGroup := self debuggerCodeCommandGroupFor: rootCommandGroup.
	commands do: [ :c | codeGroup register: c ].

	toolbarSindarinGroup := CmCommandGroup forSpec
			beToolbarPopoverButton;
			name: ''Advanced'';
			icon: (stDebuggerInstance application iconNamed: #smallDebugIt);
			yourself.
	(self debuggerToolbarCommandGroupFor: rootCommandGroup) register: toolbarSindarinGroup.
	commands do: [ :c | toolbarSindarinGroup register: c ].'
	
]

{ #category : 'interactions' }
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

{ #category : 'interactions' }
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

	activationBlock value: value'
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> instrumentSystem [
	"self instrumentDebuggerOpening."
	"self logTextEditorsClipbardActions."
	"self logClyBrowsersOpenings."
	self logCodeInteractions.
	"self logDebuggerInteractions.
	self logHaltAndBreakpointEvents.
	self logInspectorInteractions.
	self logMouseEvents.
	self listenToWindowEvents.
	self listenToMethodChanges"
]

{ #category : 'debugpoints  ' }
DSSpyInstrumenter >> listenToDebugPointChanges [

	DebugPoint codeSupportAnnouncer weak when: DebugPointAdded send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointHit send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointRemoved send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointChanged send: #recordDebugPointEvent: to: DSSpy
]

{ #category : 'methods' }
DSSpyInstrumenter >> listenToMethodChanges [
	SystemAnnouncer uniqueInstance weak when: MethodModified send: #methodChanged: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodRemoved send: #methodRemoved: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodAdded send: #methodAdded: to: DSSpy
]

{ #category : 'windows' }
DSSpyInstrumenter >> listenToWindowEvents [

	self currentWorld announcer when: WindowOpened send: #logWindowOpened: to: DSSpy.
	self currentWorld announcer when: WindowClosed send: #logWindowClosed: to: DSSpy.
	self currentWorld announcer when: WindowActivated send: #logWindowActivated: to: DSSpy
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logClyBrowsersOpenings [
	self instrumentClyQueryBrowser
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logCodeInteractions [

	self instrumentPrintIt.
	self instrumentDebugIt.
	self instrumentDoIt
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logDebuggerInteractions [

	self instrumentCodePresenter.
	self instrumentDebuggerCommands.
	self instrumentDebuggerStack.
	self instrumentSindarinDebuggerCommands
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logHaltAndBreakpointEvents [
	self instrumentHaltHits.
	self listenToDebugPointChanges 
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logInspectorInteractions [

	self instrumentExpandAttribute.
	self instrumentInspectMethodsOfClass.
	self instrumentInspectSourceOfMethod.
	self instrumentInspectorOnObject.
	self instrumentInspectorPageSelection.
	self instrumentNavigateAttribute
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logMouseEvents [

	self instrumentMouseDownFTSelectableMorph.
	self instrumentMouseEnterFTSelectableMorph.
	self instrumentMouseEnterWindow.
	self instrumentMouseLeaveWindow.
	self instrumentRubScrollTextMorphHandleMouseOver.
	self instrumentRubScrollTextMorphMouseEnter
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logTextEditorsClipbardActions [

	self instrumentRubEditorCopySelection.
	self instrumentRubEditorPaste.
	self instrumentRubSmalltalkEditorCopySelection.
	self instrumentRubSmalltalkEditorPaste.
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy 
]

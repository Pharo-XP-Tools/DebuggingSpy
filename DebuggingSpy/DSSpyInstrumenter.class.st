"
I instrument the system by adding spying instructions (directly in the code, by meta-programming, or by registering to system-events)
"
Class {
	#name : #DSSpyInstrumenter,
	#superclass : #Object,
	#category : #DebuggingSpy
}

{ #category : #'debugger- actions' }
DSSpyInstrumenter >> debuggerActionClasses [
	^ {StStepIntoCommand.
	StStepOverCommand.
	StStepThroughCommand.
	StWhereIsCommand.
	StReturnValueCommand.
	StRestartCommand.
	StRunToSelectionCommand.
	StProceedCommand}
]

{ #category : #browsers }
DSSpyInstrumenter >> instrumentCalypsoBrowsers [
	ClyFullBrowser compile: 'newWindowTitle
	| newTitle |
	
	packageView selection isEmpty ifTrue: [ ^self systemScope description].	
	
	newTitle := self buildTitleFromSelections.
	self systemScope isCurrentImage ifFalse: [ 
		newTitle := newTitle , '' in '', self systemScope description ].
	DSSpy log: newTitle key: #BROWSE.
	^newTitle'.
	
	ClyQueryBrowser compile: 'newWindowTitle
	| title | 
	title := systemQuery description.
	resultView areItemsLoaded 
		ifTrue: [title := title capitalized , '' ['' ,  self itemCount asString, '']'']
		ifFalse: [title := ''Loading: '', title ].
	
	self systemScope isCurrentImage ifFalse: [ 
		title := title , '' in '', self systemScope description ].
	DSSpy log: title key: #BROWSE.
	^title'.
	
	TabGroupMorph compile: 'updatePageIndex: index
	"Change to the given page index."

	self pageMorph ifNotNil: [:p | self contentMorph removeMorph: p].
	index > 0 ifTrue: [self contentMorph addMorph: (self pages at: index). 
			DSSpy log: (self pages at: index) labelString key: #BROWSE. ].

	self pageMorph ifNotNil: [:pm | pm layoutChanged].
	self adoptPaneColor: self paneColor'
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentDebugIt [

RubSmalltalkEditor compile: 'debugSelection
	"Treat the current selection as an expression; evaluate and debugg it in a new debugger."

	self lineSelectAndEmptyCheck: [ ^ self ].
	[DSSpy log: self selection asString key: #ACTION_DEBUGIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
	self debug: self selectionAsStream'.
	
SpCodeDebugItCommand compile: 'execute
	| selection |
	
	selection := self selectedTextOrLine.
	selection ifEmpty: [ ^ String new ].
	[DSSpy log: selection asString key: #ACTION_DEBUGIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
	self debug: selection readStream'.
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebugger [
	self instrumentDebuggerCode.
	self instrumentDebuggerStack 
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerCode [

	StDebugger compile: 'initializeCode
	self flag: #DBG_IMPROVE.
	 "Add metalink information in the gutter!"
	
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
	codeHeader label: self session name'
]

{ #category : #debugger }
DSSpyInstrumenter >> instrumentDebuggerStack [

	StDebugger compile: 'initializeStack
	stackTable := self newTable.
	stackTable
		addColumn:
			(SpStringTableColumn
				title: ''Class''
				evaluated: [ :item | item receiver class ]);
		addColumn:
			(SpStringTableColumn
				title: ''Method''
				evaluated: [ :item | item method selector ]);
		addColumn:
			(SpStringTableColumn
				title: ''Context''
				evaluated: [ :item | item sender stDisplayString ]).
	stackTable
		transmitDo: [ :context | 
			stackTable selection isEmpty
				ifFalse: [ self updateInspectorFromContext: context.
					self updateCodeFromContext: context.
					self updateTitle.
					self expandStackIfLastItemIsSelected.
					[DSSpy log: context key: #DEBUGGER_VIEW] on: Error do:[ DSSpy log: #ERROR key: #DEBUGGER_VIEW ] ] ].
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
						key: #DEBUGGERACTION printString).
			self rewriteSourceFrom: (c >> #execute) ast in: sourceStream.
			c compile: sourceStream contents ]
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentDoIt [

	RubSmalltalkEditor compile: 'doIt
	"Set the context to include pool vars of the model.  Then evaluate."
	[DSSpy log: self selection asString key: #ACTION_DOIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DOIT ].
	^ self evaluateSelection'.
	
SpCodeDoItCommand compile: 'execute
	"Treat the current text selection as an expression; evaluate it."
	| selection |	
	selection := self selectedTextOrLine.
	[DSSpy log: selection asString key: #ACTION_DOIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DOIT ].
	self evaluateSelectionAndDo: [ :result | ]'.
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspector [

	self instrumentRawInspection.
	self instrumentMetaInspection.
	self instrumentNotebooks
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentMetaInspection [

	StMetaBrowser compile: 'updateSourceWith: method
	source userActionDuring: [
		method
			ifNotNil: [ 
				[DSSpy log: method name key: #INSPECTOR_META_METHOD] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_METHOD].
				source text: method sourceCode; beForMethod: method  ]
			ifNil: [ 
				source text: ''''; clearInteractionModel ] ]'.
	
	
	StMetaBrowser compile: 'methodsOf: aClass
	aClass ifNil: [ ^ #() ].
	[DSSpy log: aClass key: #INSPECTOR_META_CLASS] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_CLASS].
	^ aClass methods sorted: #selector ascending'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentNotebooks [

	StObjectInspector compile: 'initializePresenters
	header := self instantiate: StHeaderBar.
	views := self newNotebook.	
	views whenSelectedPageChangedDo: [ :page | 
		[DSSpy log: page title key: #INSPECTOR_VIEW] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_CLASS ] ] .
	evaluator := self newCode
		beForObject: self model inspectedObject;
		yourself.
	evaluator text: self evaluatorInitialText.
	self refresh'.
]

{ #category : #playground }
DSSpyInstrumenter >> instrumentPlayground [
	self instrumentPlaygroundCode
]

{ #category : #playground }
DSSpyInstrumenter >> instrumentPlaygroundCode [

	StPlayground compile: 'initializePresenters
	text := self newCode
		interactionModel: StPlaygroundInteractionModel new;
		lineNumbers: self showLineNumbers;
		contextMenu: [ self menuActions asMenuPresenter ];
		contextKeyBindings: self menuActions asKMCategory;
		whenTextChangedDo: [ :aString | page contents: aString ];
		yourself.		
		
	text eventHandler
		whenKeyUpDo: [ :event | self updateLineNumber ];
		whenMouseUpDo: [ :event | self updateLineNumber ];
		"before taking focus position will be nil, ensure I have the correct one"
		whenFocusReceivedDo: [ self updateLineNumber ].
		
	text eventHandler whenKeyDownDo:[:evt| 
		[DSSpy log: #SCRIPTING_WRITE key: #PLAYGROUND_WRITE] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_WRITE ] ].

	text eventHandler whenMouseEnterDo:[:evt| 
		[DSSpy log: #SCRIPTING_START key: #PLAYGROUND_READ] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_READ ] ].
		
	self updatePresenter'
	
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentPrintIt [
	ClyTextEditor compile: 'printIt
	| printString |
	[DSSpy log: self selection asString key: #ACTION_PRINTIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	self
		evaluateSelectionAndDo: [ :result | 
			printString := [ result asScriptResultStringInCalypso ]
				on: Error
				do: [ ''<error in printString: try ''''Inspect it'''' to debug>'' ].
			self afterSelectionInsertAndSelect: printString ]'.
		
	RubSmalltalkEditor compile: 'printIt
	| printString |
	[DSSpy log: self selection asString key: #ACTION_PRINTIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	self
		evaluateSelectionAndDo: [ :result | 
			printString := [ result printString ]
				on: Error
				do: [ ''<error in printString: try ''''Inspect it'''' to debug>'' ].
			self afterSelectionInsertAndSelect: printString ]'.
	
SpCodePrintItCommand compile: 'execute
	"Treat the current text selection as an expression; evaluate it."
	| selection |	
	selection := self selectedTextOrLine.
	[DSSpy log: selection asString key: #ACTION_PRINTIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_PRINTIT ].
	self evaluateSelectionAndDo: [ :result | 
		self printObject: result ]'.
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentRawInspection [

	FTBasicItem compile: 'expandAndRefresh
	[DSSpy log: data key key: #INSPECTOR_OBSERVE] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_OBSERVE].
	self expand.
	self refreshTable'.
	
	StRawInspection compile: 'setAttributeTable

	attributeTable
		roots: self inspectorNodes;
		children: [ :node | node children ].
		
	self outputSelectionPort transmitDo:[:val| 
		[DSSpy log: val key key: #INSPECTOR_OBSERVE] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_OBSERVE]].
	self outputActivationPort transmitDo:[:val| 
		[DSSpy log: val key key: #INSPECTOR_OBSERVE] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_OBSERVE]].'.

	StInspector class compile: 'onObject: anObject
	DSSpy log: anObject key: #INSPECTOR_INSPECT.
	^ self on: (StInspectorModel on: anObject)'
]

{ #category : #playground }
DSSpyInstrumenter >> instrumentRubScrolledTextMorph [
	RubScrolledTextMorph compile: 'whenKeystrokeInTextArea: anAnnouncement   
		[DSSpy log: anAnnouncement key: #CODE_WRITE] on: Error do:[ DSSpy log: #ERROR key: #CODE_WRITE ].
		self announcer announce: (anAnnouncement copy morph: self)'.
		
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

{ #category : #'system-queries' }
DSSpyInstrumenter >> instrumentSystemQueries [
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

	^'DSSpy log: {1} key: {2}.'
]

{ #category : #breakpoints }
DSSpyInstrumenter >> listenToBreakpointChanges [
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
DSSpyInstrumenter >> listenToBreakpointHits [
	self halt.
	self haltOnce.
	self halt: 'test'.
	self haltIf:["with comment" true]
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
	[|sender log|
		sender := thisContext sender sender sender sender sender sender sender sender sender sender.
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ].
	super signalIn: ctx'.
	
	Halt class compile: 'signal: s
		[|sender log|
		sender := thisContext sender sender sender sender sender .
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ].
	super signal: s'.
	
	Halt class compile: 'signal
		[|sender log|
		sender := thisContext sender sender sender sender sender .
		log := {sender method. sender sourceNodeExecuted sourceCode}.	
		DSSpy log: log key: #HALT_HIT] 
		on: Error 
		do:[ DSSpy log: #ERROR key: #HALT_HIT ].
	super signal'.
]

{ #category : #methods }
DSSpyInstrumenter >> listenToMethodChanges [
	SystemAnnouncer uniqueInstance weak when: MethodModified send: #methodChanged: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodRemoved send: #methodRemoved: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodAdded send: #methodAdded: to: DSSpy
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

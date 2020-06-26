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
DSSpyInstrumenter >> instrumentCodeActions [
	self instrumentDebugIt.
	self instrumentDoIt.
	self instrumentPrintIt
]

{ #category : #interactions }
DSSpyInstrumenter >> instrumentDebugIt [

RubSmalltalkEditor compile: 'debug: aStream
	| method receiver context |
	[DSSpy log: aStream contents asString key: #ACTION_DEBUGIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
	(self model respondsTo: #doItReceiver)
		ifTrue: [ receiver := self model doItReceiver.
			context := self model doItContext ]
		ifFalse: [ receiver := context := nil ].
	method := self compile: aStream for: receiver in: context.
	method isReturnSpecial
		ifTrue: [ self inform: ''Nothing to debug, the expression is optimized''.
			^ self ].
	method notNil
		ifTrue: [ self debug: method receiver: receiver in: context ]'.
	
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

{ #category : #interactions }
DSSpyInstrumenter >> instrumentGTCodeActions [
	
	Announcement subclass: #GLMHighlightAndEvaluate
	instanceVariableNames: 'action key'
	classVariableNames: ''
	package: 'Glamour-Presentations-Announcements'.
	
	GLMHighlightAndEvaluate compile: 'key ^key'.
	GLMHighlightAndEvaluate compile: 'key: k key := k'.
	
	GLMRubricTextPresentation compile: 'highlightEvaluateAndDo: aBlock key: k
					self announce: (GLMHighlightAndEvaluate new action: aBlock; key: k)'.
					
	GLMMorphicPharoCodeRenderer compile: 'popupPrint
	"Evaluates selected code and prints it in a popper"
	textMorph textArea editor highlightEvaluateAndDo: [ :result | 
		[DSSpy log: textMorph text asString key: #ACTION_PRINTIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_PRINTIT ].
		textMorph shoutStyler style: textMorph text.
		GLMPrintPopper new 
			openFromRubric: textMorph textArea withResult: result ]'.
		
	GLMMorphicPharoCodeRenderer compile: 'debugHighlightedText

	UIManager default defer: [ 
		[DSSpy log: textMorph text asString key: #ACTION_DEBUGIT] on: Error do:[ DSSpy log: #ERROR key: #ACTION_DEBUGIT ].
		textMorph textArea editor debugHighlight.
		textMorph shoutStyler style: textMorph text. ]'.
					
	GLMMorphicPharoCodeRenderer compile: 'actOnHighlightAndEvaluate: ann 

	"We get here as a result of an announcement.
	If we do not defer the execution and an exception is triggered by the execution of the code
	then resuming the execution in the debugger will trigger an error when unwinding the stack."
	UIManager default defer: [ 
		textMorph textArea handleEdit: [
			textMorph textArea editor highlightEvaluateAndDo: ann action.
			[DSSpy log: textMorph text asString key: ann key asString] on: Error do:[ DSSpy log: #ERROR key: #ACTION_GT ].
			textMorph shoutStyler style: textMorph text. ] ] '.
	
	GLMPharoScriptPresentation compile: 'goAction
	^ GLMGenericAction new
				title: ''Do it and go'';
				action: [ :t :entity |
					t highlightEvaluateAndDo: [ :result | t selection: result ] key: #ACTION_GO]; 
				shortcut: $g; 
				yourself.'.
	GTPlayground compile: 'codeIn: a
	^ (self codePresentationIn: a)
		title: [ :page | 
			GTPlaygroundEditableTabLabel new
				text: page title;
				when: #accepted
					do: [ :text | page setTitleAndEnsureInStash: text asString ];
				yourself ];
		format: [ :page | page content ];
		act: [ :text :page | 
				text selectionInterval: (1 to: text text size).
				text highlightEvaluateAndDo: [ :result | text selection: result ] key: #ACTION_GO ]
			icon: GLMUIThemeExtraIcons glamorousGo
			on: $G
			entitled: ''Do it all and go'';
		act: [ :text :page | page publish ]
			iconName: #glamorousSaveToUrl
			entitled: ''Remote publish'';
		addAction:
			(GLMPopupAction new
				action: [ :text :page :popup | 
					GTPlaygroundBindingsList new
						on: self currentBindingsSorted;
						when: #bindingRemoved
							do: [ :binding | self removeBinding: binding ];
						when: #inspect do: [ :binding | binding value inspect ];
						when: #go do: [ :binding | text selection: binding value ];
						yourself ];
				iconName: #glamorousTable;
				title: ''Bindings'';
				yourself);
		addAction:
			(GLMPopupAction new
				action: [ :text :page :popup | 
					GTPlaygroundPlayPagesList new
						on: GTPlayBook instance;
						when: #pageAccepted
							do: [ :playPage | 
							text entity saveContent: playPage content.
							text update ];
						yourself ];
				iconName: #glamorousMore;
				title: ''Play pages'';
				yourself);
		with: [ :presentation | self pageActionsIn: presentation ];
		dynamicActionsOnSelection: [ self contextMenuActions ];
		onChangeOfPort: #text
			act: [ :text :page | 
			page saveContent: text text.
			text clearUserEdits ]'.
					
	GLMRubricSmalltalkCodePresentation compile: 'executionSelectionActions

	^ { 
		GLMGenericAction new 
				title: ''Do it'';
				action: [ :aPresentation |
					aPresentation highlightEvaluateAndDo: [ :result | ] key: #ACTION_DOIT]; 
				keymap: PharoShortcuts current doItShortcut; 
				icon: GLMUIThemeExtraIcons glamorousSpawn;
				yourself.
		GLMGenericAction new 
				title: ''Print it'';
				action: [ :aPresentation |					
					aPresentation printSelection ]; 
				keymap: PharoShortcuts current printItShortcut; 
				yourself.
		GLMGenericAction new 
				title: ''Inspect it''; 
				action: [ :aPresentation |					
					aPresentation highlightEvaluateAndDo: [ :result | result inspect ] key: #ACTION_INSPECT ]; 
				keymap: PharoShortcuts current inspectItShortcut; 
				icon: GLMUIThemeExtraIcons glamorousInspect;
				yourself.
		GLMGenericAction new 
				title: ''Basic Inspect it''; 
				action: [ :aPresentation |
					aPresentation highlightEvaluateAndDo: [ :result | result basicInspect ] key: #ACTION_INSPECT ]; 
				shortcut: $I; 
				icon: GLMUIThemeExtraIcons glamorousInspect;
				yourself.
		GLMGenericAction new 
				title: ''Debug it''; 
				action: [ :aPresentation |					
					aPresentation debugSelection ]; 
				shortcut: $D;
				yourself.
		GLMGenericAction new 
				title: ''Profile it''; 
				action: [ :aPresentation |
					aPresentation profileSelection ]; 
				withSeparatorAfter;
				yourself.
		 }'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentGTMetaInspection [

	GTSimpleMethodsBrowser compile: 'methodsIn: a
	^ a list
		title: ''Methods'';
		display: [ :object :class | 
			[DSSpy log: class key: #INSPECTOR_META_CLASS] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_CLASS]. 			
			class methods collect: [:each | each asRingDefinition]];
		filterOn: [ :text :each | (text , ''*'') match: each selector ];
		helpMessage:  ''Wildcard filtering (e.g., "*pattern*")'';
		tags: [ :method | method category ];
		sorted: [ :method1 :method2 | method1 selector < method2 selector ];
		format: [ :method | method selector ];
		morphicSelectionAct: [ :list :object :class | 
			Smalltalk tools browser 
				openOnClass: class 
				selector: list selection selector ]
			icon: GLMUIThemeExtraIcons glamorousBrowse
			on: $b
			entitled: ''Browse'';
		dynamicActionsOnSelection: [ :list | self methodActionsFor: list selection ]'.	
	

	GTSimpleMethodsBrowser compile: 'sourceOf: method for: object in: composite
	^ composite pharoMethod 
		display: [ :m | 
			[DSSpy log: m name key: #INSPECTOR_META_METHOD] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_META_METHOD].
			m sourceCode ];
		smalltalkClass: [ :m | m methodClass ];
		doItReceiver: [ object ];
		selectionPopulate: #evaluatedObject
			on: $g
			entitled: ''Do it and go''
			with: [ :text | Smalltalk compiler receiver: object; evaluate: text selectedText ];
		installDefaultSelectionActions;
		selectionAct: [ :text | self updateOuterPaneFrom: text for: method ]
			icon: GLMUIThemeExtraIcons glamorousAccept
			on: $s
			entitled: ''Accept'''
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentGTRawInspection [

	GTRawObjectVariablesBrowser compile: 'compose
	self title: ''Raw''.
	self tabulator with: [ :browser |
		browser row: #variables; row: #evaluator.
		browser transmit 
			to: #variables; 
			andShow: [:a | self variablesIn: a ].
		browser transmit 
			to: #evaluator; 
			andShow: [:a | self evaluatorIn: a ].
		browser transmit 
			from: #variables; 
			toOutsidePort: #selection; 
			transformed: [ :aNode | 
				[DSSpy log: aNode value key: #INSPECTOR_OBSERVE] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_OBSERVE].			
				aNode ifNotNil: [aNode value]].
		browser transmit 
			from: #evaluator; 
			toOutsidePort: #selection ].
	self wantsAutomaticRefresh: true'
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspector [

	self instrumentRawInspection.
	self instrumentMetaInspection.
	self instrumentNotebooks
]

{ #category : #inspector }
DSSpyInstrumenter >> instrumentInspectorTabs [

	GTInspector compile: 'addPaneFromOuter: aPort 
	"This method adds a new pane at the end of the finder."
	|newPane |
	newPane := self panes addLast: (GLMPane named: (self panes size + 1) asString in: self).
	[DSSpy log: (newPane port: #entity) value value key: #INSPECTOR_NAVIGATE] on: Error do:[ DSSpy log: #ERROR key: #INSPECTOR_NAVIGATE].	
	self newFirstTransmission
		addActiveOrigin: aPort; 
		destination: (newPane port: #entity); 
		transmit'.
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

{ #category : #windows }
DSSpyInstrumenter >> instrumentMouseEnterWindow [

	SystemWindow compile: 'handleMouseEnter: anEvent
	|log|
	log := DSSpy windowName: self.
	[DSSpy log: log key: #WINDOW_ENTER] on: Error do:[ DSSpy log: #ERROR key: #WINDOW_ENTER ]	.
	^super handleMouseEnter: anEvent'
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
	
	[DSSpy log: #SCRIPTING_START key: #PLAYGROUND_OPEN] on: Error do:[ DSSpy log: #ERROR key: #PLAYGROUND_OPEN ].
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

{ #category : #windows }
DSSpyInstrumenter >> instrumentWindows [

	self instrumentMouseEnterWindow.
	self listenToWindowEvents 
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

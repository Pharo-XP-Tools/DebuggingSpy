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

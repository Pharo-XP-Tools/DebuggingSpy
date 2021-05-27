Extension { #name : #DSSpyInstrumenter }

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpyInstrumenter >> instrumentationSourceTemplate [

	^'[DSSpy log: {1} key: {2}] on: Error do:[DSSpy log: #ERROR key: {2}].'
]

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpyInstrumenter >> logString: aString key: aKey [
	^ self instrumentationSourceTemplate
		format:
			{aString.
			aKey}
]

{ #category : #'*DebuggingSpy-Deprecated' }
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

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpyInstrumenter >> rewriteSourceFrom: ast in: stream [
	ast statements
		do: [ :stmt | 
			stream cr.
			stream << stmt sourceCode.
			stream << '.' ]
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpyInstrumenter >> rewriteTempsFrom: ast in: stream [
	ast temporaryNames ifEmpty: [ ^ self ].
	stream << $|.
	ast temporaryNames
		do: [ :tempName | 
			stream << tempName.
			stream space ].
	stream << $|
]

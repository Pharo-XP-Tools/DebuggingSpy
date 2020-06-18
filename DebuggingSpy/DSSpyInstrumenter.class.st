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

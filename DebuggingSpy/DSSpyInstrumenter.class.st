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
			sourceStream << 'execute'.
			sourceStream cr.
			sourceStream
				<<
					(self instrumentationSourceTemplate
						format:
							{c defaultName printString.
							#DEBUGGERACTION printString}).
			(c >> #execute) ast statements
				do: [ :ast | 
					sourceStream cr.
					sourceStream << ast sourceCode.
					sourceStream << '.' ].
			c compile: sourceStream contents ]
]

{ #category : #helpers }
DSSpyInstrumenter >> instrumentationSourceTemplate [

	^'DSSpy log: {1} key: {2}.'
]

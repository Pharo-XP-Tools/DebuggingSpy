Extension { #name : 'StDebugger' }

{ #category : '*DebuggingSpy' }
StDebugger class >> buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup [

	| toolbarGroup |
	toolbarGroup := self executionCommandGroupIn: rootCommandGroup.
	StDebuggerToolbarCommandTreeBuilder basicNew
		executionControlCommandClasses do: [ :ec |
		self replaceSubclass: ec inCommanderGroup: toolbarGroup ]
]

{ #category : '*DebuggingSpy' }
StDebugger class >> buildSindarinExtentionCommandsGroupWith: stDebuggerInstance forRoot: rootCommandGroup [

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
			name: 'Advanced';
			icon: (stDebuggerInstance application iconNamed: #smallDebugIt);
			yourself.
	(self debuggerToolbarCommandGroupFor: rootCommandGroup) register: toolbarSindarinGroup.
	commands do: [ :c | toolbarSindarinGroup register: c ].
]

{ #category : '*DebuggingSpy' }
StDebugger class >> executionCommandGroupIn: rootCommandGroup [

	^ rootCommandGroup / StDebuggerToolbarCommandTreeBuilder groupName
	  /
	  StDebuggerToolbarCommandTreeBuilder basicNew
		  executionControlGroupName
]

{ #category : '*DebuggingSpy' }
StDebugger class >> instrumentCommandsWith: stDebuggerInstance forRoot: rootCommandGroup [

	<extensionCommands>
	DSSpy recordingSession ifTrue: [ self buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup ]
]

{ #category : '*DebuggingSpy' }
StDebugger class >> replaceSubclass: ec inCommanderGroup: toolbarGroup [

	| subcls |
	subcls := ec allSubclasses.
	subcls isEmpty ifTrue: [ ^ self ].
	self
		transformDebuggerCommandNamed: ec defaultName
		as: subcls first
		in: toolbarGroup entries
]

{ #category : '*DebuggingSpy' }
StDebugger class >> specCommandNamed: aString inGroup: aGroup [

	^ aGroup detect: [ :c | c decoratedCommand name = aString ]
]

{ #category : '*DebuggingSpy' }
StDebugger class >> transformDebuggerCommandNamed: aDebuggerCommandUniqueName as: aDSDebuggerCommand in: aDebuggerCommandGroup [

	| originalCommand |
	originalCommand := self
		                   specCommandNamed: aDebuggerCommandUniqueName
		                   inGroup: aDebuggerCommandGroup.
	originalCommand decoratedCommand:
		(aDSDebuggerCommand forContext: originalCommand context)
]

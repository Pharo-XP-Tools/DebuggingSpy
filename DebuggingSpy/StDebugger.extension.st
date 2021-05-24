Extension { #name : #StDebugger }

{ #category : #'*DebuggingSpy' }
StDebugger class >> buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup [

	| toolbarGroup |
	toolbarGroup := self executionCommandGroupIn: rootCommandGroup.
	StDebuggerToolbarCommandTreeBuilder basicNew
		executionControlCommandClasses do: [ :ec | 
		self replaceSubclass: ec inCommanderGroup: toolbarGroup ]
]

{ #category : #'*DebuggingSpy' }
StDebugger class >> executionCommandGroupIn: rootCommandGroup [

	^ rootCommandGroup / StDebuggerToolbarCommandTreeBuilder groupName
	  /
	  StDebuggerToolbarCommandTreeBuilder basicNew
		  executionControlGroupName
]

{ #category : #'*DebuggingSpy' }
StDebugger class >> instrumentCommandsWith: stDebuggerInstance forRoot: rootCommandGroup [

	self buildInstrumentedCommandsWith: stDebuggerInstance forRoot: rootCommandGroup
]

{ #category : #'*DebuggingSpy' }
StDebugger class >> replaceSubclass: ec inCommanderGroup: toolbarGroup [

	| subcls |
	subcls := ec allSubclasses.
	subcls isEmpty ifTrue: [ ^ self ].
	self
		transformDebuggerCommandNamed: ec defaultName
		as: subcls first
		in: toolbarGroup entries
]

{ #category : #'*DebuggingSpy' }
StDebugger class >> specCommandNamed: aString inGroup: aGroup [

	^ aGroup detect: [ :c | c decoratedCommand name = aString ]
]

{ #category : #'*DebuggingSpy' }
StDebugger class >> transformDebuggerCommandNamed: aDebuggerCommandUniqueName as: aDSDebuggerCommand in: aDebuggerCommandGroup [

	| originalCommand |
	originalCommand := self
		                   specCommandNamed: aDebuggerCommandUniqueName
		                   inGroup: aDebuggerCommandGroup.
	originalCommand decoratedCommand:
		(aDSDebuggerCommand forContext: originalCommand context)
]

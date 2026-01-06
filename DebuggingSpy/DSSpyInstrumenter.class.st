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

{ #category : 'system instrumentation' }
DSSpyInstrumenter class >> stopInstrumentation [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy.
	DebugPoint codeSupportAnnouncer unsubscribe: DSSpy.
	self currentWorld announcer unsubscribe: DSSpy.
	
	MetaLink uninstallAll "TO CHANGED : just uninstall targeted MetaLinks"
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentBrowseActions [

	ClyBrowserMorph link: DSBrowseRecord link toAST: (ClyBrowserMorph >> #prepareInitialStateBy:) ast
	"SpBrowseClassCommand link: DSBrowseRecord link toAST: (SpBrowseClassCommand >> #execute) ast"
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentCopySelection [

	RubTextEditor link: DSClipboardCopyRecord link toAST: (RubTextEditor >> #copySelection) ast.
	RubSmalltalkEditor link: DSClipboardCopyRecord link toAST: (RubSmalltalkEditor >> #copySelection) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentDebugIt [
	"Instruments different debugIt methods"

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

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentDoIt [
	"Instruments different doIt methods"

	RubSmalltalkEditor link: DSDoItRecord link toAST: (RubSmalltalkEditor >> #doIt) ast.
	SpCodePrintItCommand link: DSDoItRecord link toAST: (SpCodeDoItCommand >> #execute) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentDoItAndGo [
	"Instruments different doEvaluateAndGo methods"

	StObjectContextPresenter link: DSDoItAndGoRecord link toAST: (StObjectContextPresenter >> #doEvaluateAndGo) ast.
	StPlaygroundPagePresenter link: DSDoItAndGoRecord link toAST: (StPlaygroundPagePresenter >> #doEvaluateAndGo) ast
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

{ #category : 'system' }
DSSpyInstrumenter >> instrumentImplementorsActions [

	ClyShowMessageImplementorCommand link: DSImplementorsRecord link toAST: (ClyShowMessageImplementorCommand >> #execute) ast.
	SpBrowseImplementorsCommand link: DSImplementorsRecord link toAST: (SpBrowseImplementorsCommand >> #execute) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentInspectIt [
	"Instruments different inspectIt methods"

	RubSmalltalkEditor link: DSInspectItRecord link toAST: (RubSmalltalkEditor >> #inspectIt) ast.
	SpCodePrintItCommand link: DSInspectItRecord link toAST: (SpCodeInspectItCommand >> #execute) ast
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentMouseEnterWindow [

	SystemWindow link: DSMouseEnterWindowRecord link toAST: (SystemWindow >> #handleMouseEnter:) ast
]

{ #category : 'mouse events' }
DSSpyInstrumenter >> instrumentMouseLeaveWindow [

	SystemWindow link: DSMouseLeaveWindowRecord link toAST: (SystemWindow >> #handleMouseLeave:) ast
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentPaste [

	RubTextEditor link: DSClipboardPasteRecord link toAST: (RubTextEditor >> #paste) ast.
	RubSmalltalkEditor link: DSClipboardPasteRecord link toAST: (RubSmalltalkEditor >> #paste) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentPrintIt [
	"Instruments different printIt methods"

	RubSmalltalkEditor link: DSPrintItRecord link toAST: (RubSmalltalkEditor >> #printIt) ast.
	ClyTextEditor link: DSPrintItRecord link toAST: (ClyTextEditor >> #printIt) ast.
	SpCodePrintItCommand link: DSPrintItRecord link toAST: (SpCodePrintItCommand >> #execute) ast
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentSendersActions [

	ClyShowMessageSenderCommand link: DSSendersRecord link toAST: (ClyShowMessageSenderCommand >> #execute) ast.
	SpBrowseSendersCommand link: DSSendersRecord link toAST: (SpBrowseSendersCommand >> #execute) ast
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

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> instrumentSystem [
	"Instrument every thing in the system, feel free to comment things you don't want to record"

	self listenToWindowEvents.
	self listenToDebugPointChanges.
	self logTextEditorsClipbardActions.
	self logMouseEvents.
	self logCodeInteractions. 
	self logBrowsingActions "self logDebuggerInteractions.
	self logHaltAndBreakpointEvents.
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
DSSpyInstrumenter >> logBrowsingActions [

	self instrumentBrowseActions.
	self instrumentImplementorsActions.
	self instrumentSendersActions
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logCodeInteractions [

	self instrumentPrintIt.
	self instrumentDebugIt.
	self instrumentDoIt.
	self instrumentDoItAndGo
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logDebuggerInteractions [

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
DSSpyInstrumenter >> logMouseEvents [

	self instrumentMouseEnterWindow.
	self instrumentMouseLeaveWindow
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logTextEditorsClipbardActions [

	self instrumentCopySelection.
	self instrumentPaste
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy 
]

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
	"Stop the instrumentation of the system"

	"Stop the recording session"
	DSSpy recordingSession: false.

	"Stop listening to events for recording"
	SystemAnnouncer uniqueInstance unsubscribe: DSSpy.
	DebugPoint codeSupportAnnouncer unsubscribe: DSSpy.
	self currentWorld announcer unsubscribe: DSSpy.
	
	"Uninstall MetaLinks used by the instrumenter"
	MetaLink uninstallAll "TO CHANGE : just uninstall targeted MetaLinks"
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentBrowseActions [
	"Instruments browse actions"

	ClyBrowserMorph link: DSBrowseRecord link toAST: (ClyBrowserMorph >> #prepareInitialStateBy:) ast "SpBrowseClassCommand link: DSBrowseRecord link toAST: (SpBrowseClassCommand >> #execute) ast"
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentCopySelection [
	"Instruments the action of copying to clipboard"

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
	"Instruments different 'Do it' actions"

	RubSmalltalkEditor link: DSDoItRecord link toAST: (RubSmalltalkEditor >> #doIt) ast.
	SpCodePrintItCommand link: DSDoItRecord link toAST: (SpCodeDoItCommand >> #execute) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentDoItAndGo [
	"Instruments different 'Do it and go' actions"

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

{ #category : 'system' }
DSSpyInstrumenter >> instrumentImplementorsActions [
	"Instruments actions to show implementors of a method"

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
	"Instruments the action of paste from clipboard"

	RubTextEditor link: DSClipboardPasteRecord link toAST: (RubTextEditor >> #paste) ast.
	RubSmalltalkEditor link: DSClipboardPasteRecord link toAST: (RubSmalltalkEditor >> #paste) ast
]

{ #category : 'interactions' }
DSSpyInstrumenter >> instrumentPrintIt [
	"Instruments different 'Print it' actions"

	RubSmalltalkEditor link: DSPrintItRecord link toAST: (RubSmalltalkEditor >> #printIt) ast.
	ClyTextEditor link: DSPrintItRecord link toAST: (ClyTextEditor >> #printIt) ast.
	SpCodePrintItCommand link: DSPrintItRecord link toAST: (SpCodePrintItCommand >> #execute) ast
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentSendersActions [
	"Instruments actions to show senders of a method or class"

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
	
	"Start debugging session"
	DSSpy recordingSession: true.

	"Listen to announcements"
	self listenToWindowEvents.
	self listenToMethodChanges.
	self listenToDebugPointChanges.
	
	"Instruments events/user's actions"
	self logClipbardActions.
	self logMouseEvents.
	self logCodeInteractions. 
	self logBrowsingActions "self logDebuggerInteraction."
]

{ #category : 'debugpoints  ' }
DSSpyInstrumenter >> listenToDebugPointChanges [
	"Listen to the announcements link to debugPoints modification and record the event"

	DebugPoint codeSupportAnnouncer weak when: DebugPointAdded send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointHit send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointRemoved send: #recordDebugPointEvent: to: DSSpy.
	DebugPoint codeSupportAnnouncer weak when: DebugPointChanged send: #recordDebugPointEvent: to: DSSpy
]

{ #category : 'methods' }
DSSpyInstrumenter >> listenToMethodChanges [
	"Listen to the announcements link to method modification and record the event"

	SystemAnnouncer uniqueInstance weak when: MethodModified send: #methodChanged: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodRemoved send: #methodRemoved: to: DSSpy.
	SystemAnnouncer uniqueInstance weak when: MethodAdded send: #methodAdded: to: DSSpy
]

{ #category : 'windows' }
DSSpyInstrumenter >> listenToWindowEvents [
	"Listen to the announcements link to windows and record the event"

	self currentWorld announcer when: WindowOpened send: #logWindowOpened: to: DSSpy.
	self currentWorld announcer when: WindowClosed send: #logWindowClosed: to: DSSpy.
	self currentWorld announcer when: WindowActivated send: #logWindowActivated: to: DSSpy
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logBrowsingActions [
	"Instrument all actions link to the Browser : browse, senders and implementors"

	self instrumentBrowseActions.
	self instrumentImplementorsActions.
	self instrumentSendersActions
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logClipbardActions [
	"Instruments commands linked to clipboard"

	self instrumentCopySelection.
	self instrumentPaste
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logCodeInteractions [
	"Instruments actions linked to code execution : do it, print it, inspect it, ..."

	self instrumentPrintIt.
	self instrumentDebugIt.
	self instrumentDoIt.
	self instrumentDoItAndGo
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logDebuggerInteractions [
	"Instruments the Debugger and the Sindarin Debugger"
	
	self instrumentDebuggerStack.
	self instrumentSindarinDebuggerCommands
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> logMouseEvents [
	"Instrument mouse events"

	self instrumentMouseEnterWindow.
	self instrumentMouseLeaveWindow
]

{ #category : 'system-instrumentation' }
DSSpyInstrumenter >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: DSSpy 
]

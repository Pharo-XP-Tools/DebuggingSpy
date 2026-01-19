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
	<example>
	"Stop the instrumentation of the system"

	"Stop the recording session"
	DSSpy recordingSession: false.

	"Stop listening to events for recording"
	SystemAnnouncer uniqueInstance unsubscribe: DSSpy.
	DebugPoint codeSupportAnnouncer unsubscribe: DSSpy.
	self currentWorld announcer unsubscribe: DSSpy.
	
	"Uninstall MetaLinks used by the instrumenter"
	DSMetaLink uninstallAll "TO CHANGE : just uninstall targeted MetaLinks"
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentBrowseActions [
	"Instruments browse actions"

	ClySpawnFullBrowserCommand link: DSBrowseRecord link toAST: (ClySpawnFullBrowserCommand>>#execute) ast.
	SpBrowseClassCommand link: DSBrowseRecord link toAST: (SpBrowseClassCommand >> #execute) ast
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

{ #category : 'exceptions' }
DSSpyInstrumenter >> instrumentExceptionSignalling [
	"Instruments exception (except halt)"

	Exception link: DSUnhandledExceptionRecord link toAST: (Exception >> #raiseUnhandledError) ast.
]

{ #category : 'system' }
DSSpyInstrumenter >> instrumentImplementorsActions [
	"Instruments actions to show implementors of a method"

	ClyShowMessageImplementorCommand link: DSImplementorsRecord link toAST: (ClyShowMessageImplementorCommand >> #execute) ast.
	ClyTextEditor link: DSImplementorsRecord link toAST: (ClyTextEditor>>#implementorsOf:) ast.
	RubSmalltalkEditor link: DSImplementorsRecord link toAST: (RubSmalltalkEditor >> #implementorsOf:) ast.
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
	ClyTextEditor link: DSSendersRecord link toAST: (ClyTextEditor>>#sendersOf:) ast.
	RubSmalltalkEditor link: DSImplementorsRecord link toAST: (RubSmalltalkEditor >> #sendersOf:) ast.
	SpBrowseSendersCommand link: DSSendersRecord link toAST: (SpBrowseSendersCommand >> #execute) ast
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
	self logClipboardActions.
	self logMouseEvents.
	self logCodeInteractions.
	self logBrowsingActions.
	"self instrumentExceptionSignalling"
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
DSSpyInstrumenter >> logClipboardActions [
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
	self instrumentInspectIt.
	self instrumentDoItAndGo
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

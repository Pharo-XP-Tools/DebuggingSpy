"
I am defining rules for recording and I am used by most of the DebuggingSpy's classes as an helper.
"
Class {
	#name : 'DSSpy',
	#superclass : 'Object',
	#classVars : [
		'HandlingError',
		'monitor'
	],
	#classInstVars : [
		'logOnlyWhenTaskStarted',
		'taskStarted',
		'logger',
		'packagesMonitoredForSourceCodeChanges',
		'recordSourceCode',
		'recordClipboardContent',
		'recordingSession',
		'scopeSourceCodeChangesRecording',
		'recordFileName',
		'testingSession'
	],
	#category : 'DebuggingSpy-Instrumentation',
	#package : 'DebuggingSpy',
	#tag : 'Instrumentation'
}

{ #category : 'task management' }
DSSpy class >> closeSurvey: aSurvey [

	| currentTaskStarted |
	logger setupLoggerBeforeSurvey: aSurvey.
	currentTaskStarted := taskStarted.

	taskStarted := true.
	DSSurveyRecord for: aSurvey.

	taskStarted := currentTaskStarted.
	logger setupLoggerAfterSurvey: aSurvey
]

{ #category : 'mutual exclusion' }
DSSpy class >> critical: aBlock [
	self monitor critical: aBlock
]

{ #category : 'logging' }
DSSpy class >> defaultLoggerClass [
	^DSSTONFileLogger
]

{ #category : 'task management' }
DSSpy class >> endTask: aTask [

	DSEndingTaskRecord for: aTask.
	logger reset.
	taskStarted := false
]

{ #category : 'task management' }
DSSpy class >> forceRunningTask: aTask [
	logger setupLoggerForTask: aTask.
	taskStarted := true
]

{ #category : 'logging' }
DSSpy class >> getRecordFileName [

	^ recordFileName ifNil: [ recordFileName := DateAndTime now asFileNameCompatibleString copyReplaceAll: '.' with: '_']
]

{ #category : 'accessing' }
DSSpy class >> handlingError: anObject [

	^ HandlingError := anObject
]

{ #category : 'logging' }
DSSpy class >> id [

	^ id ifNil: [ id := UUID new ]
]

{ #category : 'events - debugpoints' }
DSSpy class >> indexesOfHaltNodesIn: aMethod [

	| haltNodes |
	haltNodes := aMethod ast allChildren select: [ :n | n isHaltNode ].
	^ haltNodes collect: [ :hn | hn selector -> (hn start to: hn stop) ]
]

{ #category : 'logging' }
DSSpy class >> log: aDSRecord [

	(self logOnlyWhenTaskStarted and: [ self taskStarted not ]) ifTrue: [ 
		^ self ].
	self critical: [ self logger log: aDSRecord ]
]

{ #category : 'logging' }
DSSpy class >> log: elements key: key [

"	HandlingError ifNil: [ HandlingError := false ].
	HandlingError ifFalse: [ 
		HandlingError := true.
		self halt.
		HandlingError := false ]."
	DSLoggingErrorRecord for: key
]

{ #category : 'accessing' }
DSSpy class >> logOnlyWhenTaskStarted [

	^ logOnlyWhenTaskStarted ifNil: [ logOnlyWhenTaskStarted := false ]
]

{ #category : 'accessing' }
DSSpy class >> logOnlyWhenTaskStarted: anObject [

	logOnlyWhenTaskStarted := anObject
]

{ #category : 'events - windows' }
DSSpy class >> logWindowActivated: anEvent [

	[ DSWindowActivatedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_ACTIVATED ]
]

{ #category : 'events - windows' }
DSSpy class >> logWindowClosed: anEvent [
	[ DSWindowClosedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_CLOSED ]
]

{ #category : 'events - windows' }
DSSpy class >> logWindowOpened: anEvent [

	| window |
	window := anEvent window.
	[ DSWindowOpenedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_OPENED ]
]

{ #category : 'accessing' }
DSSpy class >> logger [

	^ logger ifNil: [ logger := self defaultLoggerClass new ]
]

{ #category : 'accessing' }
DSSpy class >> logger: anObject [

	logger := anObject
]

{ #category : 'serialize/materialize' }
DSSpy class >> materialize: aFilename [

	^STON fromString: aFilename asFileReference contents
]

{ #category : 'events - methods' }
DSSpy class >> methodAdded: evt [

	[ 
	| method |
	method := evt method.
	DSMethodAddedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInAddedMethod: method ] ]
		on: Error
		do: [ :e | self log: #ERROR key: #METHOD_ADDED ]
]

{ #category : 'events - methods' }
DSSpy class >> methodChanged: evt [

	[ 
	| oldMethod newMethod |
	oldMethod := evt oldMethod.
	newMethod := evt method.

	DSMethodModifiedRecord for: newMethod.
	self recordSourceCodeChangeFrom: oldMethod to: newMethod.

	(oldMethod containsHalt and: [ newMethod containsHalt not ]) ifTrue: [ 
		self recordHaltInRemovedMethod: oldMethod ].
	(oldMethod containsHalt not and: [ newMethod containsHalt ]) ifTrue: [ 
		self recordHaltInAddedMethod: newMethod ].
	(oldMethod containsHalt and: [ newMethod containsHalt ]) ifTrue: [ 
		self recordHaltInMethod: oldMethod modifiedBy: newMethod ] ]
		on: Error
		do: [ self log: #ERROR key: #METHOD_MODIFIED ]
]

{ #category : 'events - methods' }
DSSpy class >> methodRemoved: evt [

	[ 
	| method |
	method := evt method.
	DSMethodRemovedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInRemovedMethod: method ] ]
		on: Error
		do: [ self log: #ERROR key: #METHOD_REMOVED ]
]

{ #category : 'accessing' }
DSSpy class >> monitor [

	^ monitor ifNil: [ monitor := Monitor new ]
]

{ #category : 'events - methods' }
DSSpy class >> monitorPackageForSourceCodeChanges: aString [ 
	self packagesMonitoredForSourceCodeChanges add: aString
]

{ #category : 'events - methods' }
DSSpy class >> packagesMonitoredForSourceCodeChanges [

	^ packagesMonitoredForSourceCodeChanges ifNil: [
		  packagesMonitoredForSourceCodeChanges := Set new ]
]

{ #category : 'accessing' }
DSSpy class >> packagesMonitoredForSourceCodeChanges: anObject [

	packagesMonitoredForSourceCodeChanges := anObject
]

{ #category : 'accessing' }
DSSpy class >> recordClipboardContent [
	"Indicates if the clipboard content should be recorded or not"

	^ recordClipboardContent ifNil: [ recordClipboardContent := false ]
]

{ #category : 'accessing' }
DSSpy class >> recordClipboardContent: anObject [

	recordClipboardContent := anObject
]

{ #category : 'events - debugpoints' }
DSSpy class >> recordDebugPointEvent: aDebugPointEvent [

	^ aDebugPointEvent recordDebugpoint
]

{ #category : 'events - debugpoints' }
DSSpy class >> recordHaltInAddedMethod: method [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: method.
	record := DSHaltChangeRecord for: DSHaltChangeRecord add.
	record haltData: nodesSelectorsWithIndexes.
	record method: method name
]

{ #category : 'events - debugpoints' }
DSSpy class >> recordHaltInMethod: oldMethod modifiedBy: newMethod [

	| oldHalts newHalts record |
	oldHalts := self indexesOfHaltNodesIn: oldMethod.
	newHalts := self indexesOfHaltNodesIn: newMethod.

	(oldHalts size = newHalts size and: [ 
		 oldHalts allSatisfy: [ :data | newHalts includes: data ] ]) 
		ifTrue: [ ^ self ].

	record := DSHaltChangeRecord for: DSHaltChangeRecord modify.
	record haltData: newHalts.
	record method: newMethod name
]

{ #category : 'events - debugpoints' }
DSSpy class >> recordHaltInRemovedMethod: oldMethod [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: oldMethod.
	record := DSHaltChangeRecord for: DSHaltChangeRecord remove.
	record haltData: nodesSelectorsWithIndexes.
	record method: oldMethod name
]

{ #category : 'accessing' }
DSSpy class >> recordSourceCode [
	"Indicates if source code should be recorded or not (when doing actions like Print It, Do It, ...)"

	^ recordSourceCode ifNil: [ recordSourceCode := false ]
]

{ #category : 'accessing' }
DSSpy class >> recordSourceCode: aBoolean [

	recordSourceCode := aBoolean
]

{ #category : 'events - methods' }
DSSpy class >> recordSourceCodeChangeFrom: oldMethod to: newMethod [

	self scopeSourceCodeChangesRecording ifTrue: [ 
		((self packagesMonitoredForSourceCodeChanges includes:
			  oldMethod package name) or: [ 
			 self packagesMonitoredForSourceCodeChanges includes:
				 newMethod package name ]) ifFalse: [ ^ self ] ].
	DSSourceCodeChangeEventRecord for: { 
			newMethod.
			oldMethod sourceCode.
			newMethod sourceCode }
]

{ #category : 'accessing' }
DSSpy class >> recordSourceCodeDisabledErrorMessage [

	^ 'Source code recording disabled'
]

{ #category : 'accessing' }
DSSpy class >> recordingSession [
	"Indicates if there is currently a recording session or not"

	^ recordingSession ifNil: [ recordingSession := false ]
]

{ #category : 'accessing' }
DSSpy class >> recordingSession: aBoolean [

	recordingSession := aBoolean
]

{ #category : 'initialization' }
DSSpy class >> resetSpy [

	logger ifNotNil: [ :l | l reset ].
	taskStarted := false.
	logOnlyWhenTaskStarted := false.
	testingSession := false.
	recordFileName := nil
]

{ #category : 'accessing' }
DSSpy class >> scopeSourceCodeChangesRecording [

	^ scopeSourceCodeChangesRecording ifNil: [
		  scopeSourceCodeChangesRecording := false ]
]

{ #category : 'accessing' }
DSSpy class >> scopeSourceCodeChangesRecording: anObject [

	scopeSourceCodeChangesRecording := anObject
]

{ #category : 'serialize/materialize' }
DSSpy class >> serialize: aDSEventRecord [

	self log: aDSEventRecord
]

{ #category : 'task management' }
DSSpy class >> startTask: aTask [

	logger setupLoggerForTask: aTask.
	taskStarted := true.
	DSStartTaskRecord for: aTask
]

{ #category : 'accessing' }
DSSpy class >> taskStarted [

	^ taskStarted ifNil: [ taskStarted := false ]
]

{ #category : 'accessing' }
DSSpy class >> testingSession [
	"Indicates if we are in a testing session"

	^ testingSession ifNil: [ testingSession := false ]
]

{ #category : 'accessing' }
DSSpy class >> testingSession: aBoolean [

	testingSession := aBoolean
]

{ #category : 'utils' }
DSSpy class >> toolInWindow: window [

	^ (window model isKindOf: SpWindowPresenter)
		  ifTrue: [ window model presenter ]
		  ifFalse: [ window model ]
]

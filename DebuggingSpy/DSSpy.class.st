"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#classVars : [
		'HandlingError',
		'monitor'
	],
	#classInstVars : [
		'logOnlyWhenTaskStarted',
		'taskStarted',
		'logger',
		'packagesMonitoredForSourceCodeChanges'
	],
	#category : #'DebuggingSpy-Instrumentation'
}

{ #category : #'task management' }
DSSpy class >> closeSurvey: aSurvey [

	| currentTaskStarted |
	logger setupLoggerBeforeSurvey: aSurvey.
	currentTaskStarted := taskStarted.

	taskStarted := true.
	DSSurveyRecord for: aSurvey.

	taskStarted := currentTaskStarted.
	logger setupLoggerAfterSurvey: aSurvey
]

{ #category : #'mutual exclusion' }
DSSpy class >> critical: aBlock [
	self monitor critical: aBlock
]

{ #category : #logging }
DSSpy class >> defaultLoggerClass [
	^DSSTONFileLogger
]

{ #category : #'task management' }
DSSpy class >> endTask: aTask [

	DSEndingTaskRecord for: aTask.
	logger reset.
	taskStarted := false
]

{ #category : #'task management' }
DSSpy class >> forceRunningTask: aTask [
	logger setupLoggerForTask: aTask.
	taskStarted := true
]

{ #category : #accessing }
DSSpy class >> handlingError: anObject [

	^ HandlingError := anObject
]

{ #category : #'events - breakpoints' }
DSSpy class >> indexesOfHaltNodesIn: aMethod [

	| haltNodes |
	haltNodes := aMethod ast allChildren select: [ :n | n isHaltNode ].
	^ haltNodes collect: [ :hn | hn selector -> (hn start to: hn stop) ]
]

{ #category : #logging }
DSSpy class >> log: aDSRecord [

	(self logOnlyWhenTaskStarted and: [ self taskStarted not ]) ifTrue: [ 
		^ self ].
	self critical: [ logger log: aDSRecord ]
]

{ #category : #logging }
DSSpy class >> log: elements key: key [

"	HandlingError ifNil: [ HandlingError := false ].
	HandlingError ifFalse: [ 
		HandlingError := true.
		self halt.
		HandlingError := false ]."
	DSLoggingErrorRecord for: key
]

{ #category : #accessing }
DSSpy class >> logOnlyWhenTaskStarted [

	^ logOnlyWhenTaskStarted ifNil:[logOnlyWhenTaskStarted := false]
]

{ #category : #accessing }
DSSpy class >> logOnlyWhenTaskStarted: anObject [

	logOnlyWhenTaskStarted := anObject
]

{ #category : #'events - windows' }
DSSpy class >> logWindowActivated: anEvent [

	[ DSWindowActivatedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_ACTIVATED ]
]

{ #category : #'events - windows' }
DSSpy class >> logWindowClosed: anEvent [
	[ DSWindowClosedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_CLOSED ]
]

{ #category : #'events - windows' }
DSSpy class >> logWindowOpened: anEvent [
	| window |
	window := anEvent window.
	[ DSWindowOpenedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_OPENED ].
	window announcer
		when: WindowActivated
		send: #logWindowActivated:
		to: self.
	window announcer when: WindowClosed send: #logWindowClosed: to: self
]

{ #category : #accessing }
DSSpy class >> logger [

	^ logger ifNil:[logger := self defaultLoggerClass new]
]

{ #category : #accessing }
DSSpy class >> logger: anObject [

	logger := anObject
]

{ #category : #'serialize/materialize' }
DSSpy class >> materialize: aFilename [

	^STON fromString: aFilename asFileReference contents
]

{ #category : #'events - methods' }
DSSpy class >> methodAdded: evt [

	[ 
	| method |
	method := evt method.
	DSMethodAddedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInAddedMethod: method ] ]
		on: Error
		do: [ :e | self log: #ERROR key: #METHOD_ADDED ]
]

{ #category : #'events - methods' }
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

{ #category : #'events - methods' }
DSSpy class >> methodRemoved: evt [

	[ 
	| method |
	method := evt method.
	DSMethodRemovedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInRemovedMethod: method ] ]
		on: Error
		do: [ self log: #ERROR key: #METHOD_REMOVED ]
]

{ #category : #accessing }
DSSpy class >> monitor [
	^monitor ifNil:[monitor := Monitor new]
]

{ #category : #'events - methods' }
DSSpy class >> monitorPackageForSourceCodeChanges: aString [ 
	self packagesMonitoredForSourceCodeChanges add: aString
]

{ #category : #'events - methods' }
DSSpy class >> packagesMonitoredForSourceCodeChanges [

	^ packagesMonitoredForSourceCodeChanges ifNil: [ 
		  packagesMonitoredForSourceCodeChanges := Set new ]
]

{ #category : #accessing }
DSSpy class >> packagesMonitoredForSourceCodeChanges: anObject [

	packagesMonitoredForSourceCodeChanges := anObject
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordBreakpointEvent: aBreakpointEvent [
	^aBreakpointEvent recordBreakpoint 
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordHaltInAddedMethod: method [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: method.
	record := DSHaltChangeRecord for: DSHaltChangeRecord add.
	record haltData: nodesSelectorsWithIndexes.
	record method: method name
]

{ #category : #'events - breakpoints' }
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

{ #category : #'events - breakpoints' }
DSSpy class >> recordHaltInRemovedMethod: oldMethod [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: oldMethod.
	record := DSHaltChangeRecord for: DSHaltChangeRecord remove.
	record haltData: nodesSelectorsWithIndexes.
	record method: oldMethod name
]

{ #category : #'events - methods' }
DSSpy class >> recordSourceCodeChangeFrom: oldMethod to: newMethod [

	((self packagesMonitoredForSourceCodeChanges includes:
		  oldMethod package name) or: [ 
		 self packagesMonitoredForSourceCodeChanges includes:
			 newMethod package name ]) ifFalse: [ ^ self ].
	DSSourceCodeChangeEventRecord for: { 
			newMethod.
			oldMethod sourceCode.
			newMethod sourceCode }
]

{ #category : #initialization }
DSSpy class >> resetSpy [

	logger ifNotNil:[:l| l reset].
	taskStarted := false.
	logOnlyWhenTaskStarted := false
]

{ #category : #'serialize/materialize' }
DSSpy class >> serialize: aDSEventRecord [

	self log: aDSEventRecord
]

{ #category : #'task management' }
DSSpy class >> startTask: aTask [

	logger setupLoggerForTask: aTask.
	taskStarted := true.
	DSStartTaskRecord for: aTask
]

{ #category : #accessing }
DSSpy class >> taskStarted [

	^ taskStarted ifNil: [ taskStarted := false ]
]

"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#classVars : [
		'monitor'
	],
	#classInstVars : [
		'loggingFilename',
		'loggingFileReference',
		'loggingDirectory',
		'logOnlyWhenTaskStarted',
		'taskStarted'
	],
	#category : #'DebuggingSpy-Instrumentation'
}

{ #category : #'mutual exclusion' }
DSSpy class >> critical: aBlock [
	self monitor critical: aBlock
]

{ #category : #accessing }
DSSpy class >> defaultLoggingDirectoryName [
	^'ds-spy'
]

{ #category : #accessing }
DSSpy class >> defaultLoggingFileName [

	^ SessionManager default currentSession id asString
]

{ #category : #'task management' }
DSSpy class >> endTask: aTask [
	DSEndingTaskRecord for: aTask.
	self resetSpy
]

{ #category : #logging }
DSSpy class >> ensureCreateLoggingFileReference [

	| fname fr |
	fname := self loggingFileName.
	fr := self loggingDirectory / fname.
	fr ensureCreateFile.
	^ fr
]

{ #category : #'task management' }
DSSpy class >> forceLoggingFileNameFor: aTask [

	loggingFilename := aTask name , '-' , self defaultLoggingFileName
]

{ #category : #'task management' }
DSSpy class >> forceRunningTask: aTask [
	self forceLoggingFileNameFor: aTask.
	taskStarted := true
]

{ #category : #'events - breakpoints' }
DSSpy class >> indexesOfHaltNodesIn: aMethod [

	| haltNodes |
	haltNodes := aMethod ast allChildren select: [ :n | n isHaltNode ].
	^ haltNodes collect: [ :hn | hn selector -> (hn start to: hn stop) ]
]

{ #category : #logging }
DSSpy class >> log: elements key: key [

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

{ #category : #logging }
DSSpy class >> logToFile: aString [

	(self logOnlyWhenTaskStarted and: [ self taskStarted not ]) ifTrue: [ 
		^ self ].
	self critical: [ self writeToFile: aString ]
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
DSSpy class >> loggingDirectory [
	^loggingDirectory ifNil:[loggingDirectory := self defaultLoggingDirectoryName asFileReference]
]

{ #category : #logging }
DSSpy class >> loggingDirectory: aStringOrFileReference [

	loggingDirectory := aStringOrFileReference asFileReferenceWithRelativePath / self defaultLoggingDirectoryName asFileReference.
	loggingDirectory ensureCreateDirectory
]

{ #category : #accessing }
DSSpy class >> loggingFileName [
	^loggingFilename ifNil:[loggingFilename := self defaultLoggingFileName]
]

{ #category : #accessing }
DSSpy class >> loggingFileReference [

	^loggingFileReference ifNil:[loggingFileReference := self ensureCreateLoggingFileReference]
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

{ #category : #initialization }
DSSpy class >> resetSpy [

	loggingFilename := nil.
	loggingFileReference := nil.
	taskStarted := false.
	logOnlyWhenTaskStarted := false
]

{ #category : #'serialize/materialize' }
DSSpy class >> serialize: aDSEventRecord [

	self logToFile: (STON toString: aDSEventRecord)
]

{ #category : #'task management' }
DSSpy class >> startTask: aTask [
	DSStartTaskRecord for: aTask.
	self forceLoggingFileNameFor: aTask.
	taskStarted := true
]

{ #category : #logging }
DSSpy class >> stream [
	^ self loggingFileReference writeStream
]

{ #category : #accessing }
DSSpy class >> taskStarted [

	^ taskStarted ifNil: [ taskStarted := false ]
]

{ #category : #logging }
DSSpy class >> writeToFile: aString [

	| str strSize firstWrite writingPosition |
	str := self stream.
	strSize := str writeStreamSize.
	firstWrite := strSize = 0.
	firstWrite ifTrue: [ str nextPut: $[ ].
	writingPosition := firstWrite
		                   ifTrue: [ str position ]
		                   ifFalse: [ strSize - 1 ].
	str position: writingPosition.
	firstWrite ifFalse: [ 
		str nextPut: $,.
		str crlf ].
	str nextPutAll: aString.
	str nextPut: $].
	str close
]

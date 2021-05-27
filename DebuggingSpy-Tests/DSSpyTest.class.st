Class {
	#name : #DSSpyTest,
	#superclass : #TestCase,
	#instVars : [
		'record',
		'browser',
		'methodEvent',
		'windowEvent',
		'instrumenter',
		'breakpoint',
		'task'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #assertions }
DSSpyTest >> assertBreakpointRecordedAs: aDSRecordClass forBreakpointEvent: aBreakpointEventClass target: aTarget [
	
	self assert: record class equals: aDSRecordClass.
	self assert: record eventName equals: aBreakpointEventClass name.
	self assert: record target equals: aTarget.
	aTarget ifNil:[	self deny: record objectCentric] 
			  ifNotNil: [self assert: record objectCentric].
	self deny: record once.
	self assert: record method equals: self breakpointedMethod name.
	self assert: record node equals: self breakpointedMethod ast printString
]

{ #category : #assertions }
DSSpyTest >> assertMethodEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record methodName equals: self methodEvent method name
]

{ #category : #assertions }
DSSpyTest >> assertMethodEventRecordedAs: aClass for: aMethod [
	self assert: record class identicalTo: aClass.
	self assert: record methodName equals: aMethod name
]

{ #category : #assertions }
DSSpyTest >> assertVariableBreakpointRecordedAs: aDSRecordClass forBreakpointEvent: aBreakpointEventClass target: aTarget [
	
	self assert: record class equals: aDSRecordClass.
	self assert: record eventName equals: aBreakpointEventClass name.
	self assert: record target equals: aTarget.
	aTarget ifNil:[	self deny: record objectCentric] 
			  ifNotNil: [self assert: record objectCentric].
	self deny: record once.
	self assert: record targetClassOrMethod equals: self breakpointedMethod name.
	self assert: record targetVariables first equals: #value.
	self assert: record accessStrategy equals: #all
]

{ #category : #assertions }
DSSpyTest >> assertWindowEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record windowId equals: self windowEvent window hash.
	self assert: record windowName equals: self windowEvent window label
]

{ #category : #helpers }
DSSpyTest >> breakpointMethod [
	|value|
	value := 4 squared.
	^value
]

{ #category : #helpers }
DSSpyTest >> breakpointedMethod [
	^self class >> #breakpointMethod
]

{ #category : #helpers }
DSSpyTest >> compileModifyMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt. self haltIf:[true]'
]

{ #category : #helpers }
DSSpyTest >> compileModifyMethodWithNoHaltChange [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt'
]

{ #category : #helpers }
DSSpyTest >> compileNewMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt'
]

{ #category : #helpers }
DSSpyTest >> compileTestMethod [
	DSFakeTextEditor compile: 'dsTestMethod ^self'
]

{ #category : #helpers }
DSSpyTest >> installBreakpoint [

	breakpoint := Breakpoint new
		              node: self breakpointedMethod ast;
		              always.
	breakpoint install
]

{ #category : #helpers }
DSSpyTest >> installVariableBreakpoint [

	breakpoint := VariableBreakpoint
		              watchVariable: #value
		              inClass: self breakpointedMethod
]

{ #category : #helpers }
DSSpyTest >> methodEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodAnnouncement new
			                 method: self class >> #methodEvent;
			                 yourself ]
]

{ #category : #helpers }
DSSpyTest >> methodModifiedEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodModified
			                 methodChangedFrom: self class >> #methodEvent
			                 to: self class >> #methodEvent
			                 oldProtocol: #test ]
]

{ #category : #helpers }
DSSpyTest >> modifyTestMethod [
	DSFakeTextEditor compile: 'dsTestMethod ^self + 1'
]

{ #category : #helpers }
DSSpyTest >> recoverTestMethod [
	^DSFakeTextEditor lookupSelector: #dsTestMethod
]

{ #category : #helpers }
DSSpyTest >> registry [
	^DSRecordRegistry current records
]

{ #category : #helpers }
DSSpyTest >> removeBreakpoint [

	breakpoint remove.
	breakpoint := nil
]

{ #category : #helpers }
DSSpyTest >> removeHaltInMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt ^self'
]

{ #category : #helpers }
DSSpyTest >> removeNewMethodWithHalt [

	(DSFakeTextEditor lookupSelector: #newMethodWithHalt) ifNotNil: [ :c | 
		c removeFromSystem ]
]

{ #category : #helpers }
DSSpyTest >> removeTestMethod [

	self recoverTestMethod removeFromSystem
]

{ #category : #running }
DSSpyTest >> setUp [

	super setUp.
	task := DSTask new.
	instrumenter := DSSpyInstrumenter new.
	DSRecordRegistry current reset
]

{ #category : #running }
DSSpyTest >> tearDown [
	instrumenter unsubscribeFromSystemAnnouncer.
	breakpoint ifNotNil: [ breakpoint remove ].
	self recoverTestMethod ifNotNil: [ self removeTestMethod ].
	self removeNewMethodWithHalt.
	DSRecordRegistry current reset.
	super tearDown
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testBreakpointAdded [

	instrumenter listenToBreakpointChanges.

	self installBreakpoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointAdded
		target: nil
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testBreakpointHit [

	self installBreakpoint.	
	instrumenter listenToBreakpointChanges.
	
	[self breakpointMethod] on: Break do:[].
	self assert: self registry size equals: 1.
	
	record := self registry first.
	self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointHit
		target: nil
	
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testBreakpointRemoved [

	self installBreakpoint.
	instrumenter listenToBreakpointChanges.

	self removeBreakpoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointRemoved
		target: nil
]

{ #category : #'tests - file handling' }
DSSpyTest >> testDefaultLoggingDirectoryName [

	self
		assert: DSSpy defaultLoggingDirectoryName
		equals: 'ds-spy'
]

{ #category : #'tests - file handling' }
DSSpyTest >> testDefaultLoggingFileName [
 	self assert: DSSpy defaultLoggingFileName equals: SessionManager default currentSession id asString
]

{ #category : #'tests - task management' }
DSSpyTest >> testEndTask [
	DSSpy endTask: task.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSEndingTaskRecord.
	self assert: record taskName equals: DSTask dsTaskDescription.
	self assert: record description equals: DSTask dsTaskDescription.
	self assert: record answer equals: DSTask dsTaskDescription
]

{ #category : #'tests - file handling' }
DSSpyTest >> testEnsureCreateLoggingFileReference [

	| fileReference |
	fileReference := DSSpy loggingDirectory / DSSpy loggingFileName.
	fileReference ensureDelete.
	self deny: fileReference exists.
	DSSpy ensureCreateLoggingFileReference.
	self assert: fileReference exists
]

{ #category : #'tests - halts events' }
DSSpyTest >> testIndexesOfHaltNodesIn [

	| haltData realHaltNode |
	self compileNewMethodWithHalt.
	haltData := DSSpy indexesOfHaltNodesIn: DSFakeTextEditor >> #newMethodWithHalt.
	realHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements first.
	self assert: haltData size equals: 1.
	self assert: haltData first key equals: realHaltNode selector.
	self assert: haltData first value equals: (realHaltNode start to: realHaltNode stop)
]

{ #category : #'tests - logging' }
DSSpyTest >> testLogKey [
	DSSpy log: nil key: #TEST.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record event equals: #TEST
]

{ #category : #'tests - logging' }
DSSpyTest >> testLogToFile [

	DSSpy loggingFileReference ensureDelete.
	DSSpy logOnlyWhenTaskStarted: false.
	DSSpy logToFile: 'test'.
	self assert: DSSpy loggingFileReference readStream contents equals: '[test]'
]

{ #category : #'tests - logging' }
DSSpyTest >> testLogToFileOnlyWhenTaskStarted [
	|str|
	str := WriteStream on: String new.
	str nextPutAll: '[test]'.
	
	DSSpy loggingFileReference ensureDelete.
	DSSpy logOnlyWhenTaskStarted: true.
	DSSpy logToFile: 'test'.
	self deny: DSSpy loggingFileReference exists.
	
	DSSpy startTask: task.	
	DSSpy logToFile: 'test'.
	self assert: DSSpy loggingFileReference readStream contents equals: str contents
]

{ #category : #'tests - window events' }
DSSpyTest >> testLogWindowActivated [
	DSSpy logWindowActivated: self windowEvent.
	
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertWindowEventRecordedAs: DSWindowActivatedRecord
]

{ #category : #'tests - window events' }
DSSpyTest >> testLogWindowClosed [

	DSSpy logWindowClosed: self windowEvent.
	
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertWindowEventRecordedAs: DSWindowClosedRecord
]

{ #category : #'tests - window events' }
DSSpyTest >> testLogWindowOpened [

	DSSpy logWindowOpened: self windowEvent.
	
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertWindowEventRecordedAs: DSWindowOpenedRecord
]

{ #category : #'tests - file handling' }
DSSpyTest >> testLoggingDirectory [

	self
		assert: DSSpy loggingDirectory
		equals: DSSpy defaultLoggingDirectoryName asFileReference 
]

{ #category : #'tests - file handling' }
DSSpyTest >> testLoggingFileName [

	self
		assert: DSSpy loggingFileName
		equals: DSSpy defaultLoggingFileName
]

{ #category : #'tests - file handling' }
DSSpyTest >> testLoggingFileNameAfterTaskEnded [

	DSSpy startTask: task.
	DSSpy endTask: task.
	self
		assert: DSSpy loggingFileName
		equals: DSSpy defaultLoggingFileName
]

{ #category : #'tests - file handling' }
DSSpyTest >> testLoggingFileNameAfterTaskStarted [
	DSSpy startTask: task.

	self
		assert: DSSpy loggingFileName
		equals: (task name, '-', DSSpy defaultLoggingFileName)
]

{ #category : #'tests - file handling' }
DSSpyTest >> testLoggingFileReference [

	| fileReference |
	fileReference := DSSpy loggingFileReference.
	self
		assert: fileReference
		equals: DSSpy loggingDirectory / DSSpy loggingFileName.
	self assert: fileReference exists
]

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodAdded [
	DSSpy methodAdded: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodAddedRecord
]

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodChanged [

	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodModifiedRecord
]

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodEventsInstrumentation [
	
	|method|
	instrumenter listenToMethodChanges.
	self compileTestMethod.
	method := self recoverTestMethod copy.
	self modifyTestMethod.
	self removeTestMethod.
	
	self assert: self registry size equals: 3.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodAddedRecord for: method.
		
	record := self registry second.	
	self assertMethodEventRecordedAs: DSMethodModifiedRecord for: method.
	
	record := self registry third.	
	self assertMethodEventRecordedAs: DSMethodRemovedRecord for: method
]

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodRemoved [
	DSSpy methodRemoved: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodRemovedRecord
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testObjectCentricBreakpointRecord [

	|target|
	target := self class basicNew.
	instrumenter listenToBreakpointChanges.
	
	breakpoint := target haltOnCallTo: #breakpointMethod.
	self assert: self registry size equals: 1.	
	record := self registry first.
	self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointAdded
		target: (DSAbstractBreakpointEventRecord basicNew printTargetInstance: target).	
	
	[target breakpointMethod] on: Break do:[].
	self assert: self registry size equals: 2.	
	record := self registry second.
	self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointHit
		target: (DSAbstractBreakpointEventRecord basicNew printTargetInstance: target).


	self removeBreakpoint.
	self assert: self registry size equals: 3.	
	record := self registry third.
		self
		assertBreakpointRecordedAs: DSBreakpointEventRecord
		forBreakpointEvent: BreakpointRemoved
		target: (DSAbstractBreakpointEventRecord basicNew printTargetInstance: target).
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testObjectCentricVariableBreakpointRecord [

	| target |
	target := self class basicNew.
	instrumenter listenToBreakpointChanges.

	breakpoint := (self breakpointedMethod newBreakpointForVariable: #value)
		              scopeTo: target;
		              install.

	self assert: self registry size equals: 1.
	record := self registry first.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointAdded
		target:
		(DSAbstractBreakpointEventRecord basicNew printTargetInstance:
			 target).

	[ target breakpointMethod ]
		on: Break
		do: [  ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointHit
		target:
		(DSAbstractBreakpointEventRecord basicNew printTargetInstance:
			 target).


	self removeBreakpoint.
	self assert: self registry size equals: 3.
	record := self registry third.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointRemoved
		target:
		(DSAbstractBreakpointEventRecord basicNew printTargetInstance:
			 target)
]

{ #category : #'tests - halts events' }
DSSpyTest >> testRecordHaltInAddedMethod [
	| haltData realHaltNode |
	instrumenter listenToMethodChanges.
	self compileNewMethodWithHalt.
	
	"We have: 
		1 - the method change record
		2 - the halt modification record"
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record class equals: DSHaltChangeRecord.	
	self assert: record haltChange equals: DSHaltChangeRecord add.
	self assert: record method equals: (DSFakeTextEditor >> #newMethodWithHalt) name.
	
	haltData := record haltData.	
	realHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements first.
	self assert: haltData size equals: 1.
	self assert: haltData first key equals: realHaltNode selector.
	self assert: haltData first value equals: (realHaltNode start to: realHaltNode stop)
]

{ #category : #'tests - halts events' }
DSSpyTest >> testRecordHaltInMethodmodifiedBy [
	| oldHaltData haltData addedHaltNode |
		
	self compileNewMethodWithHalt.
	oldHaltData := DSSpy indexesOfHaltNodesIn: (DSFakeTextEditor >> #newMethodWithHalt).
	instrumenter listenToMethodChanges.
	
	self compileModifyMethodWithNoHaltChange.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSMethodModifiedRecord.	
		
	self compileModifyMethodWithHalt.
	
	"We have: 
		2 - the method change record
		3 - the halt modification record"
	self assert: self registry size equals: 3.
	record := self registry third.
	self assert: record class equals: DSHaltChangeRecord.	
	self assert: record haltChange equals: DSHaltChangeRecord modify.
	self assert: record method equals: (DSFakeTextEditor >> #newMethodWithHalt) name.
	
	haltData := record haltData.	
	self assert: haltData size equals: 2.
	self assert: haltData first key equals: oldHaltData first key.
	self assert: haltData first value equals: oldHaltData first value.
	
	addedHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements second.
	self assert: haltData second key equals: addedHaltNode selector.
	self assert: haltData second value equals: (addedHaltNode start to: addedHaltNode stop)
]

{ #category : #'tests - halts events' }
DSSpyTest >> testRecordHaltInRemovedMethod [
	| haltData methodName realHaltNode |
		
	self compileNewMethodWithHalt.
	instrumenter listenToMethodChanges.
	realHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements first.
	methodName := (DSFakeTextEditor >> #newMethodWithHalt) name.
	self removeNewMethodWithHalt.
	
	"We have: 
		1 - the method change record
		2 - the halt modification record"
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record class equals: DSHaltChangeRecord.	
	self assert: record haltChange equals: DSHaltChangeRecord remove.	
	self assert: record method equals: methodName.
	
	haltData := record haltData.	
	self assert: haltData size equals: 1.
	self assert: haltData first key equals: realHaltNode selector.
	self assert: haltData first value equals: (realHaltNode start to: realHaltNode stop)
]

{ #category : #'tests - halts events' }
DSSpyTest >> testRecordRemoveHaltInMethodmodified [
	| haltData realHaltNode |
	self compileNewMethodWithHalt.
	instrumenter listenToMethodChanges.
	realHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements first.
		
	self removeHaltInMethodWithHalt.
	
	"We have: 
		1 - the method change record
		2 - the halt modification record"
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record class equals: DSHaltChangeRecord.	
	self assert: record haltChange equals: DSHaltChangeRecord remove.
	self assert: record method equals: (DSFakeTextEditor >> #newMethodWithHalt) name.	
	
	haltData := record haltData.	
	self assert: haltData size equals: 1.
	self assert: haltData first key equals: realHaltNode selector.
	self assert: haltData first value equals: (realHaltNode start to: realHaltNode stop)
]

{ #category : #'tests - task management' }
DSSpyTest >> testResetSpy [

	DSSpy startTask: task.
	DSSpy resetSpy.
	self deny: DSSpy taskStarted.
	self
		assert: DSSpy loggingFileName
		equals: DSSpy defaultLoggingFileName
]

{ #category : #'tests - task management' }
DSSpyTest >> testStartTask [
	
	DSSpy startTask: task.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSStartTaskRecord.
	self assert: record taskName equals: DSTask dsTaskDescription.
	self assert: record description equals: DSTask dsTaskDescription
]

{ #category : #'tests - task management' }
DSSpyTest >> testTaskStarted [

	self deny: DSSpy taskStarted.
	DSSpy startTask: task.
	self assert: DSSpy taskStarted.
	DSSpy endTask: task.
	self deny: DSSpy taskStarted
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointAdded [
	instrumenter listenToBreakpointChanges.

	self installVariableBreakpoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointAdded
		target: nil

]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointAddedToMultipleVariables [

	instrumenter listenToBreakpointChanges.

	breakpoint := VariableBreakpoint watchVariablesInClass:
		              DSTestClassWithInstanceVariables.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertCollection: record targetVariables
		equals:
		(DSTestClassWithInstanceVariables allSlots collect: [ :s | s name ])
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointHit [
		
	self installVariableBreakpoint.
	instrumenter listenToBreakpointChanges.
	[ self breakpointMethod  ] on: Break do:[].

	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointHit
		target: nil
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointRemoved [
	
	self installVariableBreakpoint.
	instrumenter listenToBreakpointChanges.
	self removeBreakpoint.

	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertVariableBreakpointRecordedAs: DSVariableBreakpointEventRecord
		forBreakpointEvent: BreakpointRemoved
		target: nil
]

{ #category : #'tests - window events' }
DSSpyTest >> testWindowOpenedListensToWindowActivatedAndClosedEvents [

	DSSpy logWindowOpened: self windowEvent.
	self windowEvent window announceActivated.
	self windowEvent window announce: (WindowClosed new
			 window: self windowEvent window;
			 yourself).
	self assert: self registry size equals: 3.

	record := self registry first.
	self assert: record class identicalTo: DSWindowOpenedRecord.

	record := self registry second.
	self assert: record class identicalTo: DSWindowActivatedRecord.

	record := self registry third.
	self assert: record class identicalTo: DSWindowClosedRecord
]

{ #category : #'tests - logging' }
DSSpyTest >> testWriteToFile [

	| str |
	DSSpy loggingFileReference ensureDelete.
	DSSpy writeToFile: 'test'.
	self
		assert: DSSpy loggingFileReference readStream contents
		equals: '[test]'.
	DSSpy writeToFile: 'test'.

	str := WriteStream on: String new.
	str << '['.
	str << 'test'.
	str << ','.
	str crlf.
	str << 'test'.
	str << ']'.

	self
		assert: DSSpy loggingFileReference readStream contents
		equals: str contents
]

{ #category : #helpers }
DSSpyTest >> windowEvent [

	^ windowEvent ifNil: [ 
		  | window |
		  window := SystemWindow basicNew.
		  window setLabel: 'DS-Test-Event'.
		  windowEvent := WindowAnnouncement new.
		  windowEvent window: window.
		  windowEvent ]
]

Class {
	#name : 'DSSpyTest',
	#superclass : 'TestCase',
	#instVars : [
		'record',
		'browser',
		'methodEvent',
		'windowEvent',
		'instrumenter',
		'debugpoint',
		'task',
		'survey',
		'recordSourceCode',
		'debugpointHash'
	],
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'helpers' }
DSSpyTest >> addOnceBehaviorToDebugPoint [

	debugpoint addBehavior: (OnceBehavior new priority: 1)
]

{ #category : 'assertions' }
DSSpyTest >> assertDebugPointRecordedAs: aDSRecordClass forDebugPointEvent: aBreakpointEventClass target: aTarget [
	
	self assert: record class equals: aDSRecordClass.
	self assert: record eventName equals: aBreakpointEventClass name.
	self assert: record target class equals: aTarget.
	self assert: record debugPointHash equals: debugpointHash
]

{ #category : 'assertions' }
DSSpyTest >> assertMethodEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record methodName equals: self methodEvent method name
]

{ #category : 'assertions' }
DSSpyTest >> assertMethodEventRecordedAs: aClass for: aMethod [
	self assert: record class identicalTo: aClass.
	self assert: record methodName equals: aMethod name
]

{ #category : 'assertions' }
DSSpyTest >> assertMethodSourceCodeNotRecorded [

	self
		assert: record methodSource
		equals: DSSpy recordSourceCodeDisabledErrorMessage
]

{ #category : 'assertions' }
DSSpyTest >> assertMethodSourceCodeRecorded [

	self
		assert: record methodSource
		equals: (self class >> #methodEvent) sourceCode
]

{ #category : 'assertions' }
DSSpyTest >> assertWindowEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record windowId equals: self windowEvent window hash.
	self assert: record windowName equals: self windowEvent window label
]

{ #category : 'helpers' }
DSSpyTest >> breakpointMethod [
	|value|
	value := 4 squared.
	^value
]

{ #category : 'helpers' }
DSSpyTest >> breakpointedMethod [
	^self class >> #breakpointMethod
]

{ #category : 'helpers' }
DSSpyTest >> compileModifyMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt. self haltIf:[true]'
]

{ #category : 'helpers' }
DSSpyTest >> compileModifyMethodWithNoHaltChange [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt'
]

{ #category : 'helpers' }
DSSpyTest >> compileNewMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt self halt'
]

{ #category : 'helpers' }
DSSpyTest >> compileTestMethod [
	DSFakeTextEditor compile: 'dsTestMethod ^self'
]

{ #category : 'helpers' }
DSSpyTest >> installBreakDebugPoint [

	debugpoint := DebugPointManager installNew: BreakDebugPoint on: self breakpointedMethod ast.
	debugpointHash := debugpoint hash
]

{ #category : 'helpers' }
DSSpyTest >> installWatchDebugPoint [

	debugpoint := DebugPointManager installNew: WatchDebugPoint inClass: DSTestClassWithInstanceVariables onVariableAccessNamed: #text.
	debugpointHash := debugpoint hash
]

{ #category : 'helpers' }
DSSpyTest >> methodEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodAnnouncement new
			                 method: self class >> #methodEvent;
			                 yourself ]
]

{ #category : 'helpers' }
DSSpyTest >> methodModifiedEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodModified
			                 methodChangedFrom: self class >> #methodEvent
			                 to: self class >> #methodEvent
			                 oldProtocol: #test ]
]

{ #category : 'helpers' }
DSSpyTest >> modifyTestMethod [
	DSFakeTextEditor compile: 'dsTestMethod ^self + 1'
]

{ #category : 'helpers' }
DSSpyTest >> recoverTestMethod [
	^DSFakeTextEditor lookupSelector: #dsTestMethod
]

{ #category : 'helpers' }
DSSpyTest >> registry [
	^DSRecordRegistry current records
]

{ #category : 'helpers' }
DSSpyTest >> removeDebugPoint [

	debugpoint remove.
	debugpoint := nil
]

{ #category : 'helpers' }
DSSpyTest >> removeHaltInMethodWithHalt [
	DSFakeTextEditor compile: 'newMethodWithHalt ^self'
]

{ #category : 'helpers' }
DSSpyTest >> removeNewMethodWithHalt [

	(DSFakeTextEditor lookupSelector: #newMethodWithHalt) ifNotNil: [ :c | 
		c removeFromSystem ]
]

{ #category : 'helpers' }
DSSpyTest >> removeTestMethod [

	self recoverTestMethod removeFromSystem
]

{ #category : 'running' }
DSSpyTest >> setUp [

	super setUp.
	task := DSTestTask new.
	survey := DSTestSurvey new.
	instrumenter := DSSpyInstrumenter new.
	DSRecordRegistry current reset.
	DSSpy packagesMonitoredForSourceCodeChanges: nil.
	recordSourceCode := DSSpy recordSourceCode.
	DSSpy recordSourceCode: false.
	DSSpy scopeSourceCodeChangesRecording: true
]

{ #category : 'running' }
DSSpyTest >> tearDown [

	DSSpy logger loggingFileReference ensureDelete.
	DSSpy resetSpy.
	DSRecordRegistry autoSerialize: false.
	instrumenter unsubscribeFromSystemAnnouncer.
	debugpoint ifNotNil: [ debugpoint remove ].
	self recoverTestMethod ifNotNil: [ self removeTestMethod ].
	self removeNewMethodWithHalt.
	DSRecordRegistry current reset.
	DSSpy recordSourceCode: recordSourceCode.
	DSSpy scopeSourceCodeChangesRecording: nil.
	super tearDown
]

{ #category : 'tests - task management' }
DSSpyTest >> testCloseSurvey [

	| taskLoggingFileName recordedSurvey |
	DSSpy logOnlyWhenTaskStarted: true.
	DSSpy startTask: task.
	DSRecordRegistry autoSerialize: true.
	taskLoggingFileName := task title , '-' , DSSpy logger defaultLoggingFileName.

	self assert: self registry size equals: 1.
	self assert: DSSpy logger loggingFileName equals: taskLoggingFileName.
	self assert: DSSpy logger loggingFileReference basename equals: taskLoggingFileName.

	DSSpy closeSurvey: survey.
	self assert: self registry size equals: 2.
	self assert: DSSpy logger loggingFileName equals: taskLoggingFileName.
	self assert: DSSpy logger loggingFileReference basename equals: taskLoggingFileName.

	record := self registry first.
	self assert: record class equals: DSStartTaskRecord.
	self assert: record taskName equals: DSTestTask dsTaskDescription.
	self assert: record description equals: DSTestTask dsTaskDescription.

	record := self registry last.
	self assert: record class equals: DSSurveyRecord.
	self assert: record answer equals: survey answer.
	self assert: record description equals: DSTestSurvey dsSurveyDescription.

	recordedSurvey := (STON fromString:
		                   (DSSpy logger loggingDirectory / (DSSpy logger filenameForSurvey: survey)) readStream contents) first.
	self assert: recordedSurvey class equals: DSSurveyRecord.
	self assert: recordedSurvey answer equals: survey answer.
	self assert: recordedSurvey description equals: DSTestSurvey dsSurveyDescription.
	(DSSpy logger loggingDirectory / (DSSpy logger filenameForSurvey: survey)) delete
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testDebugPointAdded [

	instrumenter listenToDebugPointChanges.

	self installBreakDebugPoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointAdded 
		target: DSDebugPointNodeTargetRecord 
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testDebugPointAddedToInstanceVariable [

	instrumenter listenToDebugPointChanges.

	debugpoint := DebugPointManager installNew: BreakDebugPoint inClass: DSTestClassWithInstanceVariables  onVariableAccessNamed: #number.
	debugpointHash := debugpoint hash.
	
	self assert: self registry size equals: 1.
	record := self registry first.
	
	self assert: record target target
		equals: '#number => InstanceVariableSlot'
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testDebugPointChanged [

	self installBreakDebugPoint.
	instrumenter listenToDebugPointChanges.

	self addOnceBehaviorToDebugPoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointChanged 
		target: DSDebugPointNodeTargetRecord 
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testDebugPointHit [

	self installBreakDebugPoint.	
	instrumenter listenToDebugPointChanges.
	
	[self breakpointMethod] on: Break do:[].
	self assert: self registry size equals: 1.
	
	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointHit 
		target: DSDebugPointNodeTargetRecord 
	
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testDebugPointRemoved [

	self installBreakDebugPoint.
	instrumenter listenToDebugPointChanges.

	self removeDebugPoint.
	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointRemoved 
		target: DSDebugPointNodeTargetRecord 
]

{ #category : 'tests - logging' }
DSSpyTest >> testDefaultLogger [
	DSSpy logger: nil.
	self assert: DSSpy logger class equals: DSSpy defaultLoggerClass 
]

{ #category : 'tests - task management' }
DSSpyTest >> testEndTask [

	DSSpy endTask: task.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSEndingTaskRecord.
	self assert: record taskName equals: DSTestTask dsTaskDescription.
	self assert: record description equals: DSTestTask dsTaskDescription.
	self assert: record answer equals: DSTestTask dsTaskDescription
]

{ #category : 'tests - halts events' }
DSSpyTest >> testIndexesOfHaltNodesIn [

	| haltData realHaltNode |
	self compileNewMethodWithHalt.
	haltData := DSSpy indexesOfHaltNodesIn: DSFakeTextEditor >> #newMethodWithHalt.
	realHaltNode := (DSFakeTextEditor >> #newMethodWithHalt) ast statements first.
	self assert: haltData size equals: 1.
	self assert: haltData first key equals: realHaltNode selector.
	self assert: haltData first value equals: (realHaltNode start to: realHaltNode stop)
]

{ #category : 'tests - logging' }
DSSpyTest >> testLog [

	DSSpy logger loggingFileReference ensureDelete.
	DSSpy logOnlyWhenTaskStarted: false.
	DSSpy log: 'test'.
	self assert: DSSpy logger loggingFileReference readStream contents equals: '[''test'']'
]

{ #category : 'tests - logging' }
DSSpyTest >> testLogKey [
	[DSSpy log: nil key: #TEST] on: Halt do:[:h| h proceed].
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record event equals: #TEST
]

{ #category : 'tests - window events' }
DSSpyTest >> testLogWindowActivated [

	DSSpy logWindowActivated: self windowEvent.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assertWindowEventRecordedAs: DSWindowActivatedRecord
]

{ #category : 'tests - window events' }
DSSpyTest >> testLogWindowClosed [

	DSSpy logWindowClosed: self windowEvent.
	
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertWindowEventRecordedAs: DSWindowClosedRecord
]

{ #category : 'tests - window events' }
DSSpyTest >> testLogWindowOpened [

	DSSpy logWindowOpened: self windowEvent.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assertWindowEventRecordedAs: DSWindowOpenedRecord
]

{ #category : 'tests - serialize/materialize' }
DSSpyTest >> testMaterialize [
	|records materializedRecords|
	DSSpy logger loggingFileReference ensureDelete.
	DSSpy resetSpy.
	records := OrderedCollection with:  (DSLoggingErrorRecord for: #TEST) with:  (DSLoggingErrorRecord for: #TEST).
	records do:[:r| DSSpy serialize: r].
	materializedRecords := DSSpy materialize: DSSpy logger loggingFileReference.
	self assert: materializedRecords size equals: 2.
	
	self assert: materializedRecords first class equals: DSLoggingErrorRecord.
	self assert: materializedRecords first dateTime equals: records first dateTime.
	self assert: materializedRecords first eventName equals: records first eventName.
	self assert: materializedRecords first event equals: records first event.
	
	self assert: materializedRecords second class equals: DSLoggingErrorRecord.
	self assert: materializedRecords second dateTime equals: records second dateTime.
	self assert: materializedRecords second eventName equals: records second eventName.
	self assert: materializedRecords second event equals: records second event
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodAdded [
	DSSpy recordSourceCode: true.
	DSSpy methodAdded: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodAddedRecord.
	self assertMethodSourceCodeRecorded
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodAddedNoSourceCode [
	DSSpy methodAdded: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodAddedRecord.
	self assertMethodSourceCodeNotRecorded
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodChanged [

	DSSpy recordSourceCode: true.
	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodModifiedRecord.
	self assertMethodSourceCodeRecorded
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodChangedNoSourceCode [

	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodModifiedRecord.
	self assertMethodSourceCodeNotRecorded
]

{ #category : 'tests - methods events' }
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

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodRemoved [

	DSSpy recordSourceCode: true.
	DSSpy methodRemoved: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodRemovedRecord.
	self assertMethodSourceCodeRecorded
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMethodRemovedNoSourceCode [
	DSSpy methodRemoved: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodRemovedRecord.
	self assertMethodSourceCodeNotRecorded
]

{ #category : 'tests - methods events' }
DSSpyTest >> testMonitorPackageForSourceCodeChanges [

	DSSpy monitorPackageForSourceCodeChanges: self class package name.
	self assert: DSSpy packagesMonitoredForSourceCodeChanges size equals: 1.
	self assert: DSSpy packagesMonitoredForSourceCodeChanges asOrderedCollection first equals: self class package name.
	
	DSSpy monitorPackageForSourceCodeChanges: self class package name.
	self assert: DSSpy packagesMonitoredForSourceCodeChanges size equals: 1.
	
	DSSpy monitorPackageForSourceCodeChanges: 'Another package'.
	self assert: DSSpy packagesMonitoredForSourceCodeChanges size equals: 2.
	self assert: (DSSpy packagesMonitoredForSourceCodeChanges includes: 'Another package').
	self assert: (DSSpy packagesMonitoredForSourceCodeChanges includes: self class package name).
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testObjectCentricBreakDebugPointRecord [

	| target |
	target := self class basicNew.
	instrumenter listenToDebugPointChanges.

	debugpoint := target breakOnCallTo: #breakpointMethod.
	debugpointHash := debugpoint hash.
	self assert: self registry size equals: 1.
	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointAdded 
		target: DSDebugPointObjectTargetRecord.

	[ target breakpointMethod ]
		on: Break
		do: [ ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointHit 
		target: DSDebugPointObjectTargetRecord.


	self removeDebugPoint.
	self assert: self registry size equals: 3.
	record := self registry third.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord
		forDebugPointEvent: DebugPointRemoved 
		target: DSDebugPointObjectTargetRecord.
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testObjectCentricVariableDebugPointRecord [

	| target |
	target := DSTestClassWithInstanceVariables new.
	instrumenter listenToDebugPointChanges.
	
	debugpoint := DebugPointManager installNew: BreakDebugPoint forObject: target onVariableAccessNamed: #text.
	debugpointHash := debugpoint hash.

	self assert: self registry size equals: 1.
	record := self registry first.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord 
		forDebugPointEvent: DebugPointAdded 
		target: DSDebugPointObjectTargetRecord.

	[ target text: 'A beautiful text' ]
		on: Break
		do: [  ].
	self assert: self registry size equals: 2.
	record := self registry second.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord 
		forDebugPointEvent: VariableDebugPointHit 
		target: DSDebugPointObjectTargetRecord.


	self removeDebugPoint.
	self assert: self registry size equals: 3.
	record := self registry third.
	self
		assertDebugPointRecordedAs: DSBreakDebugPointEventRecord 
		forDebugPointEvent: DebugPointRemoved 
		target: DSDebugPointObjectTargetRecord 
]

{ #category : 'tests - methods events' }
DSSpyTest >> testPackagesMonitoredForSourceCodeChanges [

	self assert: DSSpy packagesMonitoredForSourceCodeChanges isEmpty
]

{ #category : 'tests - halts events' }
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

{ #category : 'tests - halts events' }
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

{ #category : 'tests - halts events' }
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

{ #category : 'tests - methods events' }
DSSpyTest >> testRecordMethodChangesSourceCode [

	|method|
	DSSpy scopeSourceCodeChangesRecording: true.
	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self deny: record class identicalTo: DSSourceCodeChangeEventRecord.
	
	DSRecordRegistry current reset.
	DSSpy monitorPackageForSourceCodeChanges: self class package name.
	DSSpy methodChanged: self methodModifiedEvent.
	
	self assert: self registry size equals: 2.
	self assert: self registry first class identicalTo: DSMethodModifiedRecord.	
	
	record := self registry second.	
	method := (self class >> #methodEvent).
	self assert: record class identicalTo: DSSourceCodeChangeEventRecord.	
	self assert: record methodName equals: method name.
	self assert: record oldSource equals: method sourceCode.
	self assert: record newSource equals: method sourceCode
]

{ #category : 'tests - methods events' }
DSSpyTest >> testRecordMethodChangesSourceCodeActivated [

	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 1.
	record := self registry first.
	self deny: record class identicalTo: DSSourceCodeChangeEventRecord
]

{ #category : 'tests - methods events' }
DSSpyTest >> testRecordMethodChangesSourceCodeNotScoped [

	DSSpy scopeSourceCodeChangesRecording: false.

	DSSpy methodChanged: self methodModifiedEvent.
	self assert: self registry size equals: 2.
	record := self registry second.
	self assert: record class identicalTo: DSSourceCodeChangeEventRecord
]

{ #category : 'tests - halts events' }
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

{ #category : 'tests - methods events' }
DSSpyTest >> testRecordSourceCodeChangeFromTo [

	|oldMethod newMethod|
	oldMethod := (self class >> #methodEvent).
	newMethod := (self class >> #methodModifiedEvent).
	
	DSSpy recordSourceCodeChangeFrom: oldMethod to: newMethod.
	self assert: self registry isEmpty.		
	
	DSSpy monitorPackageForSourceCodeChanges: self class package name.
	DSSpy recordSourceCodeChangeFrom: oldMethod to: newMethod.
	
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class identicalTo: DSSourceCodeChangeEventRecord.	
	self assert: record methodName equals: newMethod name.
	self assert: record oldSource equals: oldMethod sourceCode.
	self assert: record newSource equals: newMethod sourceCode
]

{ #category : 'tests - configuration' }
DSSpyTest >> testRecordSourceCodeDefaultValue [
	DSSpy recordSourceCode: nil.
	self deny: DSSpy recordSourceCode 
]

{ #category : 'tests - task management' }
DSSpyTest >> testResetSpy [

	DSSpy startTask: task.
	DSSpy resetSpy.
	self deny: DSSpy taskStarted.
	self assert: DSSpy logger loggingFileName equals: DSSpy logger defaultLoggingFileName
]

{ #category : 'tests - methods events' }
DSSpyTest >> testScopeSourceCodeChangesRecording [
	DSSpy scopeSourceCodeChangesRecording: nil.
	self deny: DSSpy scopeSourceCodeChangesRecording
]

{ #category : 'tests - serialize/materialize' }
DSSpyTest >> testSerialize [

	record := DSLoggingErrorRecord for: #TEST.
	DSSpy serialize: record.
	self
		assert: DSSpy logger loggingFileReference contents
		equals: '[' , (STON toString: record) , ']'
]

{ #category : 'tests - task management' }
DSSpyTest >> testStartTask [

	DSSpy startTask: task.
	self assert: self registry size equals: 1.
	record := self registry first.
	self assert: record class equals: DSStartTaskRecord.
	self assert: record taskName equals: DSTestTask dsTaskDescription.
	self assert: record description equals: DSTestTask dsTaskDescription
]

{ #category : 'tests - task management' }
DSSpyTest >> testStartTaskSerialization [

	| recordedTask |
	DSSpy logger loggingDirectory deleteAllChildren.
	DSRecordRegistry autoSerialize: true.
	DSSpy resetSpy.
	DSSpy startTask: task.
	recordedTask := (DSSpy materialize: DSSpy logger loggingFileReference) first.
	self assert: recordedTask class equals: DSStartTaskRecord.
	self assert: recordedTask taskName equals: task title
]

{ #category : 'tests - task management' }
DSSpyTest >> testTaskStarted [

	self deny: DSSpy taskStarted.
	DSSpy startTask: task.
	self assert: DSSpy taskStarted.
	DSSpy endTask: task.
	self deny: DSSpy taskStarted
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testWatchDebugPointAdded [
	| history |

	history := OrderedCollection new.
	instrumenter listenToDebugPointChanges.

	self installWatchDebugPoint.
	self assert: self registry size equals: 1.
	record := self registry first.
	self
		assertDebugPointRecordedAs: DSWatchDebugPointEventRecord
		forDebugPointEvent: DebugPointAdded 
		target: DSDebugPointInstanceVariableTargetRecord 

]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testWatchDebugPointChangedBehavior [

	self installWatchDebugPoint.
	instrumenter listenToDebugPointChanges.
	
	self addOnceBehaviorToDebugPoint.

	self assert: self registry size equals: 1.

	record := self registry first.
	self assertDebugPointRecordedAs: DSWatchDebugPointEventRecord forDebugPointEvent: DebugPointChanged target: DSDebugPointInstanceVariableTargetRecord 
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testWatchDebugPointHit [

	self installWatchDebugPoint.
	instrumenter listenToDebugPointChanges.
	[ DSTestClassWithInstanceVariables new ]
		on: Break
		do: [ ].

	self assert: self registry size equals: 2.

	record := self registry first.
	self
		assertDebugPointRecordedAs: DSWatchDebugPointEventRecord
		forDebugPointEvent: VariableDebugPointHit
		target: DSDebugPointInstanceVariableTargetRecord.

	record := self registry second.
	self
		assertDebugPointRecordedAs: DSWatchDebugPointEventRecord
		forDebugPointEvent: DebugPointChanged
		target: DSDebugPointInstanceVariableTargetRecord
]

{ #category : 'tests - debugpoints events' }
DSSpyTest >> testWatchDebugPointRemoved [
	
	self installWatchDebugPoint.
	instrumenter listenToDebugPointChanges.
	self removeDebugPoint.

	self assert: self registry size equals: 1.

	record := self registry first.
	self
		assertDebugPointRecordedAs: DSWatchDebugPointEventRecord
		forDebugPointEvent: DebugPointRemoved 
		target: DSDebugPointInstanceVariableTargetRecord 
]

{ #category : 'tests - window events' }
DSSpyTest >> testWindowOpenedListensToWindowActivatedAndClosedEvents [

	DSSpy logWindowOpened: self windowEvent.
	DSSpy logWindowActivated: windowEvent window announceActivated.
	DSSpy logWindowClosed: (windowEvent window announce: (WindowClosed new
			 window: self windowEvent window;
			 yourself)).
	self assert: self registry size equals: 3.

	record := self registry first.
	self assert: record class identicalTo: DSWindowOpenedRecord.
	
	record := self registry second.
	self assert: record class identicalTo: DSWindowActivatedRecord.

	record := self registry third.
	self assert: record class identicalTo: DSWindowClosedRecord
]

{ #category : 'helpers' }
DSSpyTest >> windowEvent [

	^ windowEvent ifNil: [ 
		  | window |
		  window := SystemWindow basicNew.
		  window setLabel: 'DS-Test-Event'.
		  windowEvent := WindowAnnouncement new.
		  windowEvent window: window.
		  windowEvent ]
]

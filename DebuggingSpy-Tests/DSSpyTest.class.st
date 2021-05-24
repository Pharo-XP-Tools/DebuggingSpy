Class {
	#name : #DSSpyTest,
	#superclass : #TestCase,
	#instVars : [
		'record',
		'browser',
		'methodEvent',
		'windowEvent',
		'instrumenter',
		'breakpoint'
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
DSSpyTest >> methodEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodAnnouncement new
			                 method: self class >> #methodEvent;
			                 yourself ]
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
DSSpyTest >> removeTestMethod [

	self recoverTestMethod removeFromSystem
]

{ #category : #running }
DSSpyTest >> setUp [

	super setUp.

	instrumenter := DSSpyInstrumenter new.
	DSRecordRegistry current reset
]

{ #category : #running }
DSSpyTest >> tearDown [
	instrumenter unsubscribeFromSystemAnnouncer.
	breakpoint ifNotNil: [ breakpoint remove ].
	self recoverTestMethod ifNotNil: [ self removeTestMethod ].
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

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodAdded [
	DSSpy methodAdded: self methodEvent.
	self assert: self registry size equals: 1.	
		
	record := self registry first.	
	self assertMethodEventRecordedAs: DSMethodAddedRecord
]

{ #category : #'tests - methods events' }
DSSpyTest >> testMethodChanged [

	DSSpy methodChanged: self methodEvent.
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
DSSpyTest >> testVariableBreakpointAdded [
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointHit [
]

{ #category : #'tests - breakpoints events' }
DSSpyTest >> testVariableBreakpointRemoved [
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

Class {
	#name : #DSSpyTest,
	#superclass : #TestCase,
	#instVars : [
		'record',
		'browser',
		'methodEvent',
		'windowEvent',
		'instrumenter'
	],
	#category : #'DebuggingSpy-Tests'
}

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
DSSpyTest >> compileTestMethod [
	DSFakeTextEditor compile: 'dsTestMethod ^self'
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
	self recoverTestMethod ifNotNil: [ self removeTestMethod ].
	DSRecordRegistry current reset.
	super tearDown
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

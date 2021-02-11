Class {
	#name : #DSSpyTest,
	#superclass : #TestCase,
	#instVars : [
		'record',
		'browser',
		'methodEvent',
		'windowEvent'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #assertions }
DSSpyTest >> assertMethodEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record methodName equals: self methodEvent method name
]

{ #category : #assertions }
DSSpyTest >> assertWindowEventRecordedAs: aClass [
	self assert: record class identicalTo: aClass.
	self assert: record windowId equals: self windowEvent window hash.
	self assert: record windowName equals: self windowEvent window label
]

{ #category : #helpers }
DSSpyTest >> methodEvent [

	^ methodEvent ifNil: [ 
		  methodEvent := MethodAnnouncement new
			                 method: self class >> #methodEvent;
			                 yourself ]
]

{ #category : #helpers }
DSSpyTest >> registry [
	^DSRecordRegistry current records
]

{ #category : #running }
DSSpyTest >> setUp [

	super setUp.


	DSRecordRegistry current reset
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

Class {
	#name : 'DSWindowRecord',
	#superclass : 'Object',
	#instVars : [
		'type',
		'name',
		'events',
		'activePeriods',
		'sourceEvent',
		'idleTime',
		'trueIdleTime'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSWindowRecord class >> for: events [ 
	^self new buildEvents: events
]

{ #category : 'accessing' }
DSWindowRecord >> activePeriods [

	^ activePeriods
]

{ #category : 'accessing' }
DSWindowRecord >> activePeriods: anObject [

	activePeriods := anObject
]

{ #category : 'adding' }
DSWindowRecord >> addIdleTime: aDuration [
	idleTime ifNil: [
		idleTime := aDuration.
		idleTime asSeconds = 40562 ifTrue: [ self halt ].	
	idleTime asSeconds = 3800 ifTrue: [ self halt ].
		^ self ].	
	idleTime := idleTime + aDuration.
	idleTime asSeconds = 40562 ifTrue: [ self halt ].	
	idleTime asSeconds = 3800 ifTrue: [ self halt ].
]

{ #category : 'building' }
DSWindowRecord >> buildEvents: aCollectionOfEvents [

	events := aCollectionOfEvents.
	self computeActivePeriods.

	type := self windowTypeFor: events first.
	type = 'ClyQueryBrowserMorph' ifTrue: [
		(events
			 detect: [ :e | e class == DSQueryBrowseRecord ]
			 ifNone: [ nil ]) ifNotNil: [ :e |
			type := (e queryName readStream upTo: Character space) capitalized.
			name := (e queryName splitOn: Character space) last ] ].


	type = 'ClyFullBrowserMorph' ifTrue: [
		type := 'Browser'.
		(events
			 detect: [ :e | e class == DSFullBrowseRecord ]
			 ifNone: [ nil ]) ifNotNil: [ :e |
			name := String streamContents: [ :ws |
				        (#( nil '' ) includes: e classBrowsed) ifFalse: [
					        ws << e classBrowsed ].
				        (#( nil '' ) includes: e methodBrowsed) ifFalse: [
					        ws << '>>'.
					        ws << e methodBrowsed ] ] ] ].
	
	name ifNotNil: [ ^ self ].
	name := self windowNameFor: events first
]

{ #category : 'building' }
DSWindowRecord >> computeActivePeriods [

	| activityStartStopEvents start stop previous |
	activePeriods := OrderedCollection new.
	activityStartStopEvents := events select: [ :e |
		                           {
			                           DSMouseEnterWindowRecord.
			                           DSMouseLeaveWindowRecord } includes:
			                           e class ].
	(activityStartStopEvents notEmpty and: [
		 activityStartStopEvents first class == DSMouseLeaveWindowRecord ])
		ifTrue: [ activityStartStopEvents removeFirst ].

	[ activityStartStopEvents isEmpty ] whileFalse: [
		| next |
		next := activityStartStopEvents removeFirst.
		next class = DSMouseEnterWindowRecord ifTrue: [
			previous class = next class ifFalse: [ start := next ] ].

		next class = DSMouseLeaveWindowRecord ifTrue: [
			| startIndex stopIndex |
			stop := next.
			startIndex := events indexOf: start.
			stopIndex := events indexOf: stop.
			startIndex > 0 ifTrue: [
				activePeriods add: (DSWindowActivityRecord
						 start: start
						 stop: stop
						 events: (events copyFrom: startIndex to: stopIndex)
						 window: self) ] ].
		previous := next ]
]

{ #category : 'accessing' }
DSWindowRecord >> events [

	^ events
]

{ #category : 'accessing' }
DSWindowRecord >> events: anObject [

	events := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> idleTime [

	^ idleTime ifNil: [ idleTime := 0 seconds ] ifNotNil: [ idleTime ]
]

{ #category : 'testing' }
DSWindowRecord >> isDebugger [

	events ifEmpty: [ ^ false ].
	^ events first class == DSDebuggerOpeningRecord
]

{ #category : 'accessing' }
DSWindowRecord >> name [

	^ name
]

{ #category : 'accessing' }
DSWindowRecord >> name: anObject [

	name := anObject
]

{ #category : 'printing' }
DSWindowRecord >> printOn: ws [
	ws << '['.
	self printTypeOn: ws.
	ws << ']'.
	ws space.
	ws << (name isString ifTrue:[name] ifFalse:[name printString]) 
]

{ #category : 'printing' }
DSWindowRecord >> printTypeOn: aStream [

	type isString ifTrue: [
		aStream << type.
		^ self ].
	aStream << 'External Window'
]

{ #category : 'accessing' }
DSWindowRecord >> sourceEvent [

	^ sourceEvent
]

{ #category : 'accessing' }
DSWindowRecord >> sourceEvent: anObject [

	sourceEvent := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> totalTime [

	^ (activePeriods
		   inject: 0
		   into: [ :sum :next | sum + next duration asSeconds ]) seconds
]

{ #category : 'accessing' }
DSWindowRecord >> trueIdleTime [

	^ trueIdleTime
		  ifNil: [ trueIdleTime := 0 asSeconds ]
		  ifNotNil: [ trueIdleTime ]
]

{ #category : 'accessing' }
DSWindowRecord >> trueIdleTime: anObject [

	trueIdleTime := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> type [

	^ type
]

{ #category : 'accessing' }
DSWindowRecord >> type: anObject [

	type := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> windowId [ 
	^events first windowId
]

{ #category : 'accessing' }
DSWindowRecord >> windowNameFor: aDSDebuggerOpeningRecord [

	^ [ aDSDebuggerOpeningRecord windowName ]
		  on: Error
		  do: [ aDSDebuggerOpeningRecord windowId ]
]

{ #category : 'accessing' }
DSWindowRecord >> windowTypeFor: aDSDebuggerOpeningRecord [ 
	
	^aDSDebuggerOpeningRecord windowType
]

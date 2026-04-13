"
I am representing windows on which a user did actions. I am built from a list of records. 
"
Class {
	#name : 'DSWindowRecord',
	#superclass : 'Object',
	#instVars : [
		'name',
		'events',
		'activePeriods',
		'sourceEvent',
		'idleTime',
		'trueIdleTime',
		'toolInfos'
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

{ #category : 'building' }
DSWindowRecord >> buildEvents: aCollectionOfEvents [

	events := aCollectionOfEvents.
	self computeActivePeriods.

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
				                           DSMouseLeaveWindowRecord } includes: e class ].
	(activityStartStopEvents notEmpty and: [ activityStartStopEvents first class == DSMouseLeaveWindowRecord ]) ifTrue: [
		activityStartStopEvents removeFirst ].

	[ activityStartStopEvents isEmpty ] whileFalse: [
			| next |
			next := activityStartStopEvents removeFirst.
			next class = DSMouseEnterWindowRecord ifTrue: [ previous class = next class ifFalse: [ start := next ] ].

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

{ #category : 'testing' }
DSWindowRecord >> isDebugger [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClass = StDebugger
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
	ws << name asString
]

{ #category : 'printing' }
DSWindowRecord >> printTypeOn: aStream [

	aStream << self windowType
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
DSWindowRecord >> toolInfo [

	^ toolInfos
]

{ #category : 'accessing' }
DSWindowRecord >> toolInfo: anObject [

	toolInfos := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> totalTime [

	^ (activePeriods sum: [ :period | period duration asSeconds ] ifEmpty: 0) seconds
]

{ #category : 'accessing' }
DSWindowRecord >> windowId [ 
	^events first windowId
]

{ #category : 'accessing' }
DSWindowRecord >> windowNameFor: aDSWindowOpeningRecord [

	^ [ aDSWindowOpeningRecord windowName ]
		  on: Error
		  do: [ aDSWindowOpeningRecord windowId ]
]

{ #category : 'accessing' }
DSWindowRecord >> windowType [

	toolInfos ifNotNil: [ ^ toolInfos windowType ].
	^ 'External Window'
]

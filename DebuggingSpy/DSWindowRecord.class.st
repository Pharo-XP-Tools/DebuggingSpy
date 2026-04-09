"
I am representing windows on which a user did actions. I am built from a list of records. 
"
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
		'trueIdleTime',
		'toolInfos'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'color' }
DSWindowRecord class >> browserColor [
	"Returns the color associated for a record that happened in a browser."

	^ Color fromHexString: '#2A2AB7'
]

{ #category : 'color' }
DSWindowRecord class >> critiqueBrowserColor [
	"Returns the color associated for a record that happened in a critique browser."

	^ Color fromHexString: '#A45C15'
]

{ #category : 'color' }
DSWindowRecord class >> debugPointBrowserColor [
	"Returns the color associated for a record that happened in a debug point browser."

	^ Color fromHexString: '#7C238C'
]

{ #category : 'color' }
DSWindowRecord class >> debuggerColor [
	"Returns the color associated for a record that happened in a debugger."

	^ Color fromHexString: '#C41E3D'
]

{ #category : 'color' }
DSWindowRecord class >> defaultColor [
	"Returns the color associated for a record that happened in an unknown window."

	^ Color gray
]

{ #category : 'color' }
DSWindowRecord class >> epiceaColor [
	"Returns the color associated for a record that happened in an Epicea window."

	^ Color fromHexString: '#345e54'
]

{ #category : 'instance creation' }
DSWindowRecord class >> for: events [ 
	^self new buildEvents: events
]

{ #category : 'color' }
DSWindowRecord class >> icebergColor [
	"Returns the color associated for a record that happened in a Iceberg window."

	^ Color fromHexString: '#2B5BA9'
]

{ #category : 'color' }
DSWindowRecord class >> inspectorColor [
	"Returns the color associated for a record that happened in an inspector."

	^ Color fromHexString: '#FFC300'
]

{ #category : 'color' }
DSWindowRecord class >> playgroundColor [
	"Returns the color associated for a record that happened in a playground."

	^ Color fromHexString: '#70B77E'
]

{ #category : 'color' }
DSWindowRecord class >> rewriterColor [
	"Returns the color associated for a record that happened in a rewriter."

	^ Color fromHexString: '#292929'
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

	type := self windowTypeFor: events first.

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

{ #category : 'accessing' }
DSWindowRecord >> getWindowType [

	toolInfos ifNotNil: [ ^ toolInfos toolClassName ].
	type isString ifTrue: [ ^ type ].
	^ 'External Window'
]

{ #category : 'testing' }
DSWindowRecord >> isBrowser [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'ClyFullBrowserMorph'
]

{ #category : 'testing' }
DSWindowRecord >> isCritiqueBrowser [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'StCritiquePackageSelectorPresenter' 
]

{ #category : 'testing' }
DSWindowRecord >> isDebugPointBrowser [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'DebugPointBrowserPresenter'
]

{ #category : 'testing' }
DSWindowRecord >> isDebugger [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'StDebugger'
]

{ #category : 'testing' }
DSWindowRecord >> isEpicea [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'EpUnifiedBrowserPresenter'
]

{ #category : 'testing' }
DSWindowRecord >> isIceberg [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'IceTipRepositoryBrowser'
]

{ #category : 'testing' }
DSWindowRecord >> isInspector [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'StInspectorPresenter'
]

{ #category : 'testing' }
DSWindowRecord >> isPlayground [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'StPlaygroundPresenter'
]

{ #category : 'testing' }
DSWindowRecord >> isQueryTool [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'ClyQueryBrowserMorph'
]

{ #category : 'testing' }
DSWindowRecord >> isRewriter [

	toolInfos ifNil: [ ^ false ].
	^ toolInfos toolClassName = 'StRewriterExpressionFinderPresenter' 
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

	aStream << self getWindowType
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
DSWindowRecord >> toolInfos [

	^ toolInfos
]

{ #category : 'accessing' }
DSWindowRecord >> toolInfos: anObject [

	toolInfos := anObject
]

{ #category : 'accessing' }
DSWindowRecord >> totalTime [

	^ (activePeriods sum: [ :period | period duration asSeconds ] ifEmpty: 0) seconds
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
DSWindowRecord >> windowNameFor: aDSWindowOpeningRecord [

	^ [ aDSWindowOpeningRecord windowName ]
		  on: Error
		  do: [ aDSWindowOpeningRecord windowId ]
]

{ #category : 'accessing' }
DSWindowRecord >> windowTypeFor: aDSDebuggerOpeningRecord [ 
	
	^aDSDebuggerOpeningRecord windowType
]

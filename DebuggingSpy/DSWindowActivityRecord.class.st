Class {
	#name : #DSWindowActivityRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'start',
		'stop',
		'events',
		'window',
		'previous',
		'next'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #'as yet unclassified' }
DSWindowActivityRecord class >> start: aDSMouseEnterWindowRecord stop: aDSMouseLeaveWindowRecord events: aCollection [

	^ self new
		  start: aDSMouseEnterWindowRecord;
		  stop: aDSMouseLeaveWindowRecord;
		  events: aCollection;
		  yourself
]

{ #category : #'as yet unclassified' }
DSWindowActivityRecord class >> start: aDSMouseEnterWindowRecord stop: aDSMouseLeaveWindowRecord events: aCollection window: aDSWindowRecord [

	^ (self
		   start: aDSMouseEnterWindowRecord
		   stop: aDSMouseLeaveWindowRecord
		   events: aCollection)
		  window: aDSWindowRecord;
		  yourself
]

{ #category : #accessing }
DSWindowActivityRecord >> duration [

	^ events last dateTime - events first dateTime
]

{ #category : #accessing }
DSWindowActivityRecord >> eventName [

	^ String streamContents: [ :ws |
		  window printTypeOn: ws.
		  ws << ':'.
		  ws space.
		  ws << self duration humanReadablePrintString ]
]

{ #category : #accessing }
DSWindowActivityRecord >> events [

	^ events
]

{ #category : #accessing }
DSWindowActivityRecord >> events: anObject [

	events := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> next [

	^ next
]

{ #category : #accessing }
DSWindowActivityRecord >> next: anObject [

	next := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> previous [

	^ previous
]

{ #category : #accessing }
DSWindowActivityRecord >> previous: anObject [

	previous := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> start [

	^ start
]

{ #category : #accessing }
DSWindowActivityRecord >> start: anObject [

	start := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> stop [

	^ stop
]

{ #category : #accessing }
DSWindowActivityRecord >> stop: anObject [

	stop := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> window [

	^ window
]

{ #category : #accessing }
DSWindowActivityRecord >> window: anObject [

	window := anObject
]

{ #category : #accessing }
DSWindowActivityRecord >> windowId [

	^ windowId ifNil: [ windowId := window windowId ]
]

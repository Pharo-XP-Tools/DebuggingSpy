Class {
	#name : #DSWindowActivityRecord,
	#superclass : #DSMouseEventRecord,
	#instVars : [
		'start',
		'stop',
		'events'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'as yet unclassified' }
DSWindowActivityRecord class >> start: aDSMouseEnterWindowRecord stop: aDSMouseLeaveWindowRecord events: aCollection [

	^ self new
		  start: aDSMouseEnterWindowRecord;
		  stop: aDSMouseLeaveWindowRecord;
		  events: aCollection;
		  yourself
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

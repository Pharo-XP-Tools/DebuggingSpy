Class {
	#name : #DSMergedWindowActivityRecord,
	#superclass : #DSWindowActivityRecord,
	#instVars : [
		'activities'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #accessing }
DSMergedWindowActivityRecord >> activities [

	^ activities
		  ifNil: [ activities := OrderedCollection new ]
		  ifNotNil: [ activities ]
]

{ #category : #accessing }
DSMergedWindowActivityRecord >> activities: anObject [

	activities := anObject
]

{ #category : #accessing }
DSMergedWindowActivityRecord >> duration [

	^ (self activities
		   inject: 0
		   into: [ :sum :n | sum + n duration asSeconds ]) asSeconds
]

{ #category : #accessing }
DSMergedWindowActivityRecord >> eventName [
	
	^ String streamContents: [ :ws |
		  self window printTypeOn: ws.
		  ws << ':'.
		  ws space.
		  ws << self duration humanReadablePrintString ]
]

{ #category : #accessing }
DSMergedWindowActivityRecord >> events [

	^ (self activities collect: #events) flattened
]

{ #category : #merging }
DSMergedWindowActivityRecord >> merge: aDSWindowActivityRecord [

	self mergeWith: aDSWindowActivityRecord
]

{ #category : #merging }
DSMergedWindowActivityRecord >> mergeWith: anActivityRecord [
	self activities add: anActivityRecord.
	windowId ifNil:[windowId := anActivityRecord windowId].
	start ifNil:[start := anActivityRecord start].
	window ifNil:[window := anActivityRecord window].
	next := anActivityRecord next.
	stop := anActivityRecord stop.
]

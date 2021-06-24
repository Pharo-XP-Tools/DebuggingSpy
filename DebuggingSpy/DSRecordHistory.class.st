"
I represent a user experiment record and expose an API to extract data from this record.
"
Class {
	#name : #DSRecordHistory,
	#superclass : #Object,
	#instVars : [
		'taskName',
		'user',
		'records',
		'windowsHistory',
		'tag'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'instance creation' }
DSRecordHistory class >> on: anArray [
	^self new processRecords: anArray
]

{ #category : #'API-history' }
DSRecordHistory >> addWindowRecord: aDSRecord [
	(self windowsHistory at: aDSRecord windowId ifAbsentPut: [OrderedCollection new]) add: aDSRecord
]

{ #category : #'API-history' }
DSRecordHistory >> buildWindowHistory [

	self records do: [ :r | r recordWindowHistoryOn: self ]
]

{ #category : #'API-history' }
DSRecordHistory >> collectTimeDiscrepancies [

	| time currentRecord disc |
	disc := 0.
	time := 0.
	currentRecord := records first.
	records do: [ :r | 
		| delta |
		delta := r dateTime asSeconds - currentRecord dateTime asSeconds.
		time := time
		        + (r dateTime asSeconds - currentRecord dateTime asSeconds).
		delta > 300 ifTrue: [ disc := disc + delta ].
		currentRecord := r ].
	^ disc
]

{ #category : #'API-history' }
DSRecordHistory >> detectTimeDiscrepancies [
	|time currentRecord|
	time := 0.
	currentRecord := records first.
	records do:[:r| |delta|
		delta := (r dateTime asSeconds - currentRecord dateTime asSeconds).
		time := time + (r dateTime asSeconds - currentRecord dateTime asSeconds).
		(delta) > 60 ifTrue:[self halt]. 		
		currentRecord := r.		
		].
	
	
]

{ #category : #initialization }
DSRecordHistory >> initialize [
	super initialize.
	self flag: 'I am not tested! Please do it!' 
]

{ #category : #accessing }
DSRecordHistory >> name [

	^ self user, ': ', self taskName, '(', tag, ')'
]

{ #category : #testing }
DSRecordHistory >> numberOfSeekerActions [

	^ (self records select: [ :r | 
		   DSSeekerActionRecord withAllSubclasses includes: r class ]) size
]

{ #category : #'API-history' }
DSRecordHistory >> numberOfSteps [

	^ (records select: [ :record | record isKindOf: DSStepActionRecord ])
		  size
]

{ #category : #initialization }
DSRecordHistory >> processRecords: array [

	self records: array.
	(self records first isKindOf: DSStartTaskRecord) ifTrue: [ 
		self taskName: self records first taskName ]
]

{ #category : #accessing }
DSRecordHistory >> records [

	^ records
]

{ #category : #accessing }
DSRecordHistory >> records: anObject [

	records := anObject
]

{ #category : #accessing }
DSRecordHistory >> tag [

	^ tag
]

{ #category : #accessing }
DSRecordHistory >> tag: anObject [

	tag := anObject
]

{ #category : #accessing }
DSRecordHistory >> taskName [

	^ taskName
]

{ #category : #accessing }
DSRecordHistory >> taskName: anObject [

	taskName := anObject
]

{ #category : #'API-history' }
DSRecordHistory >> timeTaken [
	"The time taken to perform the recording of user events.
	The time is calculated as:
	- last log minus the first log timestamp minus time gaps (or discrepancies)
	- time gaps are calculated as the sum of time differences between two following events with a time delta > 5 min.
	We consider that, if the user did not do anything (basically typing or moving the mouse) for more than 5 min, the she was away from the task."
	^ ((records last dateTime asSeconds - records first dateTime asSeconds
	   - self collectTimeDiscrepancies) / 60) asFloat
]

{ #category : #accessing }
DSRecordHistory >> user [

	^ user
]

{ #category : #accessing }
DSRecordHistory >> user: anObject [

	user := anObject
]

{ #category : #accessing }
DSRecordHistory >> windowsHistory [
	^windowsHistory ifNil:[windowsHistory := Dictionary new]
]

{ #category : #accessing }
DSRecordHistory >> windowsHistory: anObject [

	windowsHistory := anObject
]

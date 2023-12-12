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
		'tag',
		'windowNames',
		'windows',
		'windowJumps'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'instance creation' }
DSRecordHistory class >> on: anArray [
	^self new processRecords: anArray
]

{ #category : #'API-history' }
DSRecordHistory >> addWindowRecord: aDSRecord [

	(self windowsHistory
		 at: (self findWindowRecordKeyForID: aDSRecord windowId)
		 ifAbsentPut: [ OrderedCollection new ]) add: aDSRecord
]

{ #category : #'private - history' }
DSRecordHistory >> allRecordsOfKind: aClass [

	^ records select: [ :record | record isKindOf: aClass ]
]

{ #category : #'API-history' }
DSRecordHistory >> breakpointAdds [

	^ (self breakpointEvents: BreakpointAdded name) size
]

{ #category : #'private - history' }
DSRecordHistory >> breakpointEvents [

	^ self records select: [ :r | r isKindOf: DSAbstractBreakpointEventRecord ]
]

{ #category : #'private - history' }
DSRecordHistory >> breakpointEvents: aBreakpointEventName [

	^ self breakpointEvents select: [ :bpEvent | 
		  bpEvent eventName = aBreakpointEventName ]
]

{ #category : #'API-history' }
DSRecordHistory >> breakpointHit [

	^ (self breakpointEvents: BreakpointHit name) size
]

{ #category : #'API-history' }
DSRecordHistory >> breakpointRemove [

	^ (self breakpointEvents: BreakpointRemoved name) size
]

{ #category : #'API-history' }
DSRecordHistory >> buildWindowHistory [

	self windowsHistory removeAll.
	self fixMissingWindowIds.
	self records do: [ :r | r recordWindowHistoryOn: self ].
	self fixWindowRecordKeysNames
]

{ #category : #initialization }
DSRecordHistory >> buildWindowJumps [

	| jumps currentWindow |
	windowJumps := OrderedCollection new.
	jumps := self allRecordsOfKind: DSMouseEnterWindowRecord.

	jumps do: [ :jumpEvent |
		(windows
			 detect: [ :w | w windowId = jumpEvent windowId ]
			 ifNone: [ nil ]) ifNotNil: [ :w |
			(w activePeriods
				 detect: [ :period | period start == jumpEvent ]
				 ifNone: [ nil ]) ifNotNil: [ :period | windowJumps add: period ] ] ]
]

{ #category : #'as yet unclassified' }
DSRecordHistory >> buildWindows [

	windows := OrderedCollection new.
	windowsHistory valuesDo: [ :events |
		windows add: (DSWindowRecord for: events) ].
	windows do: [ :w |
		| sourceEventIndex |
		sourceEventIndex := (records indexOf: w events first) - 1.
		sourceEventIndex > 0 ifTrue: [
			w sourceEvent: (records at: sourceEventIndex) ] ]
]

{ #category : #'API-history' }
DSRecordHistory >> callStackBrowing [

	^ (self allRecordsOfKind: DSBrowseContextRecord) size
]

{ #category : #'private - history' }
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
DSRecordHistory >> countDebugActions [

	^ self breakpointAdds + self breakpointHit + self breakpointRemove
	  + self executedCode + self methodsAdded + self methodsModified
	  + self methodsRemoved + self numberOfSteps + self openedDebuggers
	  + self callStackBrowing
]

{ #category : #'private - history' }
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

{ #category : #'as yet unclassified' }
DSRecordHistory >> eventsAfter: aDateAndTime [ 
	^records select:[:e| e dateTime > aDateAndTime]
]

{ #category : #'as yet unclassified' }
DSRecordHistory >> eventsBefore: aDateAndTime [ 
	self shouldBeImplemented.
]

{ #category : #'API-history' }
DSRecordHistory >> executedCode [

	^ (self allRecordsOfKind: DSCodeActionRecord) size
]

{ #category : #'private - history' }
DSRecordHistory >> findWindowRecordKeyForID: id [

	^ self windowsHistory keys
		  detect: [ :k | k windowId = id ]
		  ifNone: [ 
			  DSRecordHistoryWindowKey new
				  windowId: id;
				  yourself ]
]

{ #category : #'private - history' }
DSRecordHistory >> fixMissingWindowIds [

	| openedWindowStack |
	openedWindowStack := Stack new.
	windowNames := Dictionary new.

	records do: [ :r | 
		r windowId ifNotNil: [ 
			({ 
				 DSWindowClosedRecord.
				 DSMouseLeaveWindowRecord } includes: r class) ifTrue: [ 
				openedWindowStack removeAllSuchThat: [ :id | r windowId = id ] ].

			({ 
				 DSWindowActivatedRecord.
				 DSMouseEnterWindowRecord.
				 DSWindowOpenedRecord } includes: r class) ifTrue: [ 
				openedWindowStack push: r windowId ].

			({ 
				 DSWindowActivatedRecord.
				 DSWindowOpenedRecord } includes: r class) ifTrue: [ 
				(#( nil '' ) includes: r windowName) ifFalse: [ 
					windowNames at: r windowId put: r windowName ] ] ].
		r windowId ifNil: [ 
			openedWindowStack isEmpty
				ifTrue: [ r windowId: -1 ]
				ifFalse: [ r windowId: openedWindowStack top ] ] ]
]

{ #category : #'private - history' }
DSRecordHistory >> fixWindowRecordKeysNames [

	windowNames keysAndValuesDo: [ :id :name | 
		(self findWindowRecordKeyForID: id) windowName: name ]
]

{ #category : #initialization }
DSRecordHistory >> initialize [
	super initialize.
	self flag: 'I am not tested! Please do it!' 
]

{ #category : #'API-history' }
DSRecordHistory >> methodsAdded [

	^ (self allRecordsOfKind: DSMethodAddedRecord) size
]

{ #category : #'API-history' }
DSRecordHistory >> methodsModified [

	^ (self allRecordsOfKind: DSMethodModifiedRecord) size
]

{ #category : #'API-history' }
DSRecordHistory >> methodsModifiedEvents [

	^ (self allRecordsOfKind: DSMethodModifiedRecord)
]

{ #category : #'API-history' }
DSRecordHistory >> methodsRemoved [

	^ (self allRecordsOfKind: DSMethodRemovedRecord) size
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

	^ (self allRecordsOfKind: DSStepActionRecord) size
]

{ #category : #'API-history' }
DSRecordHistory >> openedDebuggers [

	^ (self allRecordsOfKind: DSDebuggerOpeningRecord) size
]

{ #category : #initialization }
DSRecordHistory >> processRecords: array [

	self records: (array reject:[:e| e windowId = 0]).
	(self records first isKindOf: DSStartTaskRecord) ifTrue: [
		self taskName: self records first taskName ].
	self buildWindowHistory.
	self buildWindows.
	self buildWindowJumps
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
	^windowsHistory ifNil:[windowsHistory := IdentityDictionary new]
]

{ #category : #accessing }
DSRecordHistory >> windowsHistory: anObject [

	windowsHistory := anObject
]

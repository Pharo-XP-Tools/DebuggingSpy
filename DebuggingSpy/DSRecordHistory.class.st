"
I represent a user experiment record and expose an API to extract data from this record.
"
Class {
	#name : 'DSRecordHistory',
	#superclass : 'Object',
	#instVars : [
		'taskName',
		'user',
		'records',
		'windowsHistory',
		'tag',
		'windowNames',
		'windows',
		'windowJumps',
		'filteredWindowJumps',
		'filteredWindows',
		'mergedWindowJumps'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'instance creation' }
DSRecordHistory class >> on: anArray [
	^self new processRecords: anArray
]

{ #category : 'instance creation' }
DSRecordHistory class >> readTrace: aStringOrFilename [
	^self on: (STON fromString: aStringOrFilename asFileReference contents)
]

{ #category : 'as yet unclassified' }
DSRecordHistory class >> windowActivationEventTypes [

	"Return a list of types that correspond to the user activating or entering a window."
	^{DSMouseEnterWindowRecord }
]

{ #category : 'as yet unclassified' }
DSRecordHistory class >> windowLeaveEventTypes [

	"Return a list of types that correspond to the user activating or entering a window."
	^{DSMouseLeaveWindowRecord. DSWindowClosedRecord  }
]

{ #category : 'API-history' }
DSRecordHistory >> addWindowRecord: aDSRecord [

	(self windowsHistory
		 at: (self findWindowRecordKeyForID: aDSRecord windowId)
		 ifAbsentPut: [ OrderedCollection new ]) add: aDSRecord
]

{ #category : 'private - history' }
DSRecordHistory >> allRecordsOfKind: aClass [

	^ records select: [ :record | record isKindOf: aClass ]
]

{ #category : 'API-history' }
DSRecordHistory >> breakpointAdds [

	^ (self breakpointEvents: BreakpointAdded name) size
]

{ #category : 'API-history' }
DSRecordHistory >> breakpointAnalysisMap [

	| report |
	report := Dictionary new.
	(self allRecordsOfKind: DSBreakpointRecord) do: [ :bp |
		(report at: bp targetClassOrMethod ifAbsentPut: [
			 DSBreakpointReport new
				 method: bp targetClassOrMethod;
				 yourself ]) add: bp ].
	^ report
]

{ #category : 'private - history' }
DSRecordHistory >> breakpointEvents [

	^ self records select: [ :r |
		  (r isKindOf: DSAbstractBreakpointEventRecord) or: [
			  r isKindOf: DSBreakpointRecord ] ]
]

{ #category : 'private - history' }
DSRecordHistory >> breakpointEvents: aBreakpointEventName [

	^ self breakpointEvents select: [ :bpEvent | 
		  bpEvent eventName = aBreakpointEventName ]
]

{ #category : 'API-history' }
DSRecordHistory >> breakpointHit [

	^ (self breakpointEvents: BreakpointHit name) size
]

{ #category : 'API-history' }
DSRecordHistory >> breakpointRemove [

	^ (self breakpointEvents: BreakpointRemoved name) size
]

{ #category : 'API-history' }
DSRecordHistory >> buildWindowHistory [

	self windowsHistory removeAll.
	self fixMissingWindowIds.
	self records do: [ :r | r recordWindowHistoryOn: self ].
	self fixWindowRecordKeysNames
]

{ #category : 'private - history' }
DSRecordHistory >> buildWindowJumps [

	| jumps previousWindowActivity nextWindowActivity |
	windowJumps := OrderedCollection new.
	jumps := self allRecordsOfKind: DSMouseEnterWindowRecord.

	jumps do: [ :jumpEvent |
		(filteredWindows
			 detect: [ :w | w windowId = jumpEvent windowId ]
			 ifNone: [ nil ]) ifNotNil: [ :w |
			(w activePeriods
				 detect: [ :period | period start == jumpEvent ]
				 ifNone: [ nil ]) ifNotNil: [ :period | windowJumps add: period ] ] ].

	filteredWindowJumps := windowJumps "reject: [ :e |
		                       e events size <= 3 or: [
			                       e stop dateTime - e start dateTime
			                       < 500 milliSeconds" "or: [ ""self halt."" ""e type = 'Finish'"" true] "" ] ]".

	previousWindowActivity := nil.
	filteredWindowJumps do: [ :period |
		period previous: previousWindowActivity.
		previousWindowActivity := period ].

	nextWindowActivity := nil.
	filteredWindowJumps reverseDo: [ :period |
		period next: nextWindowActivity.
		nextWindowActivity := period ].
	
	self mergeFilteredWindowJumps
	
]

{ #category : 'private - history' }
DSRecordHistory >> buildWindows [

	windows := OrderedCollection new.
	windowsHistory valuesDo: [ :events |
		windows add: (DSWindowRecord for: events) ].
	self reconstructSourcesOfDebuggerOpenings.

	filteredWindows := windows reject: [ :w |
		                   (w totalTime < 0.5 seconds or: [
			                    (w respondsTo: #type) and: [
				                    #( 'Finish' 'Post-task' 'Survey' ) includes:
					                    w type ] ]) or: [ w windowId = -1 ] ]
]

{ #category : 'API-history' }
DSRecordHistory >> callStackBrowing [

	^ (self allRecordsOfKind: DSBrowseContextRecord) size
]

{ #category : 'private - history' }
DSRecordHistory >> collectTimeDiscrepancies [

	| time currentRecord deltas |
	time := 0.
	deltas := OrderedCollection new.
	currentRecord := records first.
	records do: [ :r |
		| delta |
		delta := r dateTime asSeconds - currentRecord dateTime asSeconds.
		time := time
		        + (r dateTime asSeconds - currentRecord dateTime asSeconds).
		delta > 30 ifTrue: [
			deltas add: {
					r.
					currentRecord.
					records } -> delta asSeconds ].
		currentRecord := r ].
	^ deltas
]

{ #category : 'API-history' }
DSRecordHistory >> countDebugActions [

	^ self breakpointAdds + self breakpointRemove + self executedCode
	  + self methodsAdded + self methodsModified + self methodsRemoved
	  + self numberOfSteps + self callStackBrowing
]

{ #category : 'private - history' }
DSRecordHistory >> detectTimeDiscrepancies [
	|time currentRecord totalDelta|
	time := 0.
	totalDelta := 0.
	currentRecord := records first.
	records do:[:r| |delta|
				((r isKindOf: DSWindowOpenedRecord) and: [
			                    'Finish task *' match:
				                    r windowName asString ]) ifTrue:[^totalDelta].
		delta := (r dateTime asSeconds - currentRecord dateTime asSeconds).
		time := time + (r dateTime asSeconds - currentRecord dateTime asSeconds).
		(delta) > 60 ifTrue:[totalDelta := totalDelta + delta]. 		
		currentRecord := r.		
		].
	^totalDelta
	
]

{ #category : 'private - history' }
DSRecordHistory >> estimateSourceEventOf: aDSDebuggerOpeningRecord from: aRecordList [

	| eventIndex previousRecord |
	eventIndex := aRecordList indexOf: aDSDebuggerOpeningRecord.

	eventIndex = 1 ifTrue: [ ^ nil ].


	(self
		 findSourceEventLike:
		 aDSDebuggerOpeningRecord primarySourcesOfWindowOpenings
		 forRecord: aDSDebuggerOpeningRecord
		 in: aRecordList) ifNotNil: [ :sourceEvent | ^ sourceEvent ].


	previousRecord := aRecordList at: eventIndex - 1.
	(previousRecord class == DSMouseEnterTableItemRecord and: [
		 previousRecord isOverTestCase ]) ifTrue: [
		^ DSRunTestRecord for: previousRecord ].


	(self
		 findSourceEventLike:
		 aDSDebuggerOpeningRecord secondarySourcesOfWindowOpenings
		 forRecord: aDSDebuggerOpeningRecord
		 in: aRecordList) ifNotNil: [ :sourceEvent | ^ sourceEvent ].


	aDSDebuggerOpeningRecord contextName = 'CompiledMethod>>#DoIt'
		ifTrue: [
			^DSDebugItRecord new
				selectedString: aDSDebuggerOpeningRecord sourceNodeCode;
				windowId: (aRecordList at: eventIndex - 1) windowId;
				yourself ].

	"self halt: 'If we get there we forgot a case...'."
	^ aRecordList at: eventIndex - 1
]

{ #category : 'API-history' }
DSRecordHistory >> eventsAfter: aDateAndTime [ 
	^records select:[:e| e dateTime > aDateAndTime]
]

{ #category : 'API-history' }
DSRecordHistory >> eventsBefore: aDateAndTime [ 
	self shouldBeImplemented.
]

{ #category : 'API-history' }
DSRecordHistory >> executedCode [

	^ (self allRecordsOfKind: DSCodeActionRecord) size
]

{ #category : 'accessing' }
DSRecordHistory >> filteredWindowJumps [

	^ filteredWindowJumps
]

{ #category : 'accessing' }
DSRecordHistory >> filteredWindows [

	^ filteredWindows
]

{ #category : 'private - history' }
DSRecordHistory >> findSourceEventLike: possibleSourceEvents forRecord: aRecord in: aRecordList [

	| eventIndex |
	eventIndex := aRecordList indexOf: aRecord.
	eventIndex - 1 to: 1 by: -1 do: [ :i |
		| previousRecord |
		previousRecord := aRecordList at: i.
		previousRecord class = aRecord class ifTrue: [ ^ nil ].
		((possibleSourceEvents includes: previousRecord class) and:[previousRecord canOpenDebuggers])
			ifTrue: [	^ previousRecord ] ].
	^ nil
]

{ #category : 'private - history' }
DSRecordHistory >> findWindowRecordKeyForID: id [

	^ self windowsHistory keys
		  detect: [ :k | k windowId = id ]
		  ifNone: [ 
			  DSRecordHistoryWindowKey new
				  windowId: id;
				  yourself ]
]

{ #category : 'private - history' }
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

{ #category : 'private - history' }
DSRecordHistory >> fixWindowIdsOf: aCollection [

	| windowlessRecords validEvents enterAndLeaveSequences currentWindowId currentSequence |

	windowlessRecords := aCollection select: [ :e | e windowId isNil ].
	validEvents := aCollection select:[ :e | (#( nil 0 ) includes: e windowId) not ].

	"First we sort all events in sequences happening in the same window"
	enterAndLeaveSequences := OrderedCollection new.
	currentWindowId := validEvents first windowId.
	currentSequence := OrderedCollection new.
	validEvents do: [:e |	
			
		(e windowId ~= currentWindowId or: [(self class windowLeaveEventTypes includes: e class)])
			ifTrue: [
				(self class windowLeaveEventTypes includes: e class) ifTrue:[currentSequence add: e].
				enterAndLeaveSequences add: currentSequence.
				currentSequence := OrderedCollection new.
				currentSequence add: e.
				currentWindowId := e windowId ]
			ifFalse: [ currentSequence add: e ] ].

	"Then for each sequence, we try to find events without window id happening between the start and the end of that sequence"
	enterAndLeaveSequences do: [ :sequence |
		| enter leave |
		enter := sequence first.
		leave := sequence last.
		(windowlessRecords select: [ :e |
			 e dateTime > enter dateTime and: [ e dateTime < leave dateTime ] ])
			do: [ :e | e windowId: enter windowId ] ]
]

{ #category : 'private - history' }
DSRecordHistory >> fixWindowRecordKeysNames [

	windowNames keysAndValuesDo: [ :id :name | 
		(self findWindowRecordKeyForID: id) windowName: name ]
]

{ #category : 'API-history' }
DSRecordHistory >> haltAnalysisMap [

	| report |
	report := Dictionary new.
	(self allRecordsOfKind: DSAbstractHaltRecord) do: [ :bp |
		(report at: bp method ifAbsentPut: [
			 DSHaltReport new
				 method: bp method;
				 yourself ]) add: bp ].
	^ report
]

{ #category : 'initialization' }
DSRecordHistory >> initialize [
	super initialize.
	self flag: 'I am not tested! Please do it!' 
]

{ #category : 'private - history' }
DSRecordHistory >> mergeFilteredWindowJumps [

	| currentJump |
	mergedWindowJumps := OrderedCollection new.
	currentJump := filteredWindowJumps first.

	[ currentJump notNil ] whileTrue: [
		currentJump next ifNil: [
			mergedWindowJumps add: currentJump.
			^ self ].
		currentJump windowId = currentJump next windowId
			ifTrue: [ currentJump merge: currentJump next ]
			ifFalse: [
				mergedWindowJumps ifNotEmpty: [
					currentJump previous: mergedWindowJumps last ].
				mergedWindowJumps add: currentJump.
				currentJump := currentJump next ] ].

	self validateMergedJumps
]

{ #category : 'accessing' }
DSRecordHistory >> mergedWindowJumps [

	^ mergedWindowJumps
]

{ #category : 'API-history' }
DSRecordHistory >> methodsAdded [

	^ (self allRecordsOfKind: DSMethodAddedRecord) size
]

{ #category : 'API-history' }
DSRecordHistory >> methodsModified [

	^ (self allRecordsOfKind: DSMethodModifiedRecord) size
]

{ #category : 'API-history' }
DSRecordHistory >> methodsModifiedEvents [

	^ (self allRecordsOfKind: DSMethodModifiedRecord)
]

{ #category : 'API-history' }
DSRecordHistory >> methodsRemoved [

	^ (self allRecordsOfKind: DSMethodRemovedRecord) size
]

{ #category : 'accessing' }
DSRecordHistory >> name [

	^ self user, ': ', self taskName, '(', tag, ')'
]

{ #category : 'API-history' }
DSRecordHistory >> numberOfSteps [

	^ (self allRecordsOfKind: DSStepActionRecord) size
]

{ #category : 'API-history' }
DSRecordHistory >> openedDebuggers [

	^ (self allRecordsOfKind: DSDebuggerOpeningRecord) size
]

{ #category : 'initialization' }
DSRecordHistory >> processRecords: array [

	self fixWindowIdsOf: array.
	"events with window id equals to 0 are automatic events triggered while opening a spec presenter while the window is not already open -> noise "
	self records:
		(array reject: [ :e | #( 0 ) includes: e windowId ]).
		
	"Transform raw events to model events"
	(self allRecordsOfKind: DSStepActionRecord) do: #asStepRecord.
	(self allRecordsOfKind: DSAbstractBreakpointEventRecord) do: #asBreakpointRecord.
	
	"Detect if we're in a specific task"	
	(self records first isKindOf: DSStartTaskRecord) ifTrue: [
		self taskName: self records first taskName ].
	
	"Windows"
	self buildWindowHistory.
	self buildWindows.
	self buildWindowJumps.
	
	"Check data consistency (raises a warning that can be proceeded)"
	self validateWindows
]

{ #category : 'private - history' }
DSRecordHistory >> reconstructSourcesOfDebuggerOpenings [

	| sortedDebuggerWindows recordsCopy |
	sortedDebuggerWindows := (windows select: [ :w | w isDebugger ])
		                         sort: [ :d1 :d2 | d1 events first dateTime < d2 events first dateTime ].

	recordsCopy := records copy asOrderedCollection.

	sortedDebuggerWindows do: [ :w |
		|sourceEvent|
		sourceEvent := (self estimateSourceEventOf: w events first from: recordsCopy).
		recordsCopy remove: w events first.
		recordsCopy remove: sourceEvent realRecord ifAbsent:[]. 			
		w sourceEvent: sourceEvent ]
]

{ #category : 'accessing' }
DSRecordHistory >> records [

	^ records
]

{ #category : 'accessing' }
DSRecordHistory >> records: anObject [

	records := anObject
]

{ #category : 'initialization' }
DSRecordHistory >> reprocessRecords [
	self processRecords: records asOrderedCollection 
]

{ #category : 'accessing' }
DSRecordHistory >> tag [

	^ tag
]

{ #category : 'accessing' }
DSRecordHistory >> tag: anObject [

	tag := anObject
]

{ #category : 'accessing' }
DSRecordHistory >> taskName [

	^ taskName
]

{ #category : 'accessing' }
DSRecordHistory >> taskName: anObject [

	taskName := anObject
]

{ #category : 'API-history' }
DSRecordHistory >> timeTaken [
	"The time taken to perform the recording of user events.
	The time is calculated as:
	- last log minus the first log timestamp minus time gaps (or discrepancies)
	- time gaps are calculated as the sum of time differences between two following events with a time delta > 5 min.
	We consider that, if the user did not do anything (basically typing or moving the mouse) for more than 5 min, the she was away from the task."
	^ ((records last dateTime asSeconds - records first dateTime asSeconds
	   - self collectTimeDiscrepancies) / 60) asFloat
]

{ #category : 'accessing' }
DSRecordHistory >> user [

	^ user
]

{ #category : 'accessing' }
DSRecordHistory >> user: anObject [

	user := anObject
]

{ #category : 'private - history' }
DSRecordHistory >> validateMergedJumps [

	1 to: mergedWindowJumps size do:[:i|
		|current next|
		current := mergedWindowJumps at: i.
		current = mergedWindowJumps last ifFalse:[ 
			|w wId| 
			next := mergedWindowJumps at: i + 1.
			self assert: next previous == current.
			self assert: current next == next.
			w := current window.
			wId := current windowId.
			
			self assert: (current events allSatisfy: [:e| e windowId = w and:[e window == w]]).
			self assert: (current events allSatisfy: [:e| e dateTime < next start dateTime])
		]
	]
]

{ #category : 'private - history' }
DSRecordHistory >> validateWindows [
	"Validates that each windows starts by a window entering or opening event, finishes by a window closing or leaving event, and that every event contained in the window happened between the opening event timestamp and the closing even timestamp"

	| erroneousWindows |
	erroneousWindows := Dictionary new.

	windows do: [ :w |
		| firstEvent lastEvent |
		firstEvent := w events first.
		lastEvent := w events last.

		({
			 DSWindowOpenedRecord.
			 DSWindowActivatedRecord.
			 DSMouseEnterWindowRecord.
			 DSDebuggerOpeningRecord.
			 DSBrowseContextRecord.
			 DSQueryBrowseRecord } includes: firstEvent class) ifFalse: [
			(erroneousWindows at: w ifAbsentPut: [ OrderedCollection new ])
				add: #opening -> firstEvent ].

		({
			 DSWindowClosedRecord.
			 DSMouseLeaveWindowRecord } includes: lastEvent class) ifFalse: [
			(erroneousWindows at: w ifAbsentPut: [ OrderedCollection new ])
				add: #closing -> lastEvent ].

		w events do: [ :e |
			(e dateTime >= firstEvent dateTime and: [
				 e dateTime <= lastEvent dateTime ]) ifFalse: [
				(erroneousWindows at: w ifAbsentPut: [ OrderedCollection new ])
					add: #timestamp -> e ] ] ].

	"erroneousWindows ifNotEmpty: [
		Warning signal: (String streamContents: [ :str |
				 str << erroneousWindows size printString.
				 str space.
				 str
				 <<
				 'potential sequence problem found in windows. This is just an information, you can proceed.' ]) ]"
]

{ #category : 'accessing' }
DSRecordHistory >> windows [
	^ windows
]

{ #category : 'accessing' }
DSRecordHistory >> windowsHistory [

	^ windowsHistory ifNil: [ windowsHistory := IdentityDictionary new ]
]

{ #category : 'accessing' }
DSRecordHistory >> windowsHistory: anObject [

	windowsHistory := anObject
]

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
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSRecordHistory class >> fromSTON: aSTONStringRecord [

	^ self on: (STON fromString: aSTONStringRecord)
]

{ #category : 'instance creation' }
DSRecordHistory class >> on: anArray [
	^self new processRecords: anArray
]

{ #category : 'instance creation' }
DSRecordHistory class >> readTrace: aStringOrFilename [

	^ self fromSTON: aStringOrFilename asFileReference contents
]

{ #category : 'constants' }
DSRecordHistory class >> windowActivationEventTypes [

	"Return a list of types that correspond to the user activating or entering a window."
	^{DSMouseEnterWindowRecord }
]

{ #category : 'constants' }
DSRecordHistory class >> windowLeaveEventTypes [

	"Return a list of types that correspond to the user activating or entering a window."
	^{DSMouseLeaveWindowRecord. DSWindowClosedRecord  }
]

{ #category : 'API-history' }
DSRecordHistory >> absoluteTimeTaken [
	"The absolute time taken to perform the recording of user events, including unmonitoring activities (interruptions or activities outside the IDE)."

	^ ((records last dateTime asSeconds - records first dateTime asSeconds)
	   / 60) asFloat
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
DSRecordHistory >> buildWindowHistory [

	self windowsHistory removeAll.
	self fixMissingWindowIds.
	records do: [ :r | self addWindowRecord: r ].
	self fixWindowRecordKeysNames
]

{ #category : 'private - history' }
DSRecordHistory >> buildWindowJumps [

	| previousWindowActivity nextWindowActivity |
	windowJumps := OrderedCollection new.

	filteredWindows do: [ :window | windowJumps addAll: window activePeriods ].
	windowJumps sort: [ :period1 :period2 | period1 start < period2 start ].

	filteredWindowJumps := windowJumps reject: [ :e | e events size <= 3 or: [ e stop dateTime - e start dateTime < 0.5 seconds ] ].

	previousWindowActivity := nil.
	filteredWindowJumps do: [ :period |
			period previous: previousWindowActivity.
			previousWindowActivity := period ].

	nextWindowActivity := nil.
	filteredWindowJumps reverseDo: [ :period |
			period next: nextWindowActivity.
			nextWindowActivity := period ]
]

{ #category : 'private - history' }
DSRecordHistory >> buildWindows [

	windows := OrderedCollection new.
	self windowsHistory valuesDo: [ :events | windows add: (DSWindowRecord for: events) ].
	self reconstructWindowsToolInfo. 
	self reconstructSourcesOfDebuggerOpenings.

	filteredWindows := windows reject: [ :w |
			                   w totalTime < 0.5 seconds or: [
				                   ((w respondsTo: #type) and: [ #( 'Finish' 'Post-task' 'Survey' ) includes: w type ]) or: [ w windowId = -1 ] ] ]
]

{ #category : 'API-history' }
DSRecordHistory >> collectScrollingPeriods [

	| i scrollingPeriods |
	i := 1.
	scrollingPeriods := OrderedCollection new.

	[ i <= records size ] whileTrue: [
			(records at: i) class = DSScrollingRecord ifTrue: [
					| start stop |
					start := (records at: i) dateTime.
					stop := (records at: i) dateTime.
					i := i + 1.
					[ i <= records size and: [ (records at: i) class = DSScrollingRecord ] ] whileTrue: [
							stop := (records at: i) dateTime.
							i := i + 1 ].
					scrollingPeriods add: {
							start.
							stop } -> (records at: i - 1) windowId ].
			i := i + 1 ].

	^ scrollingPeriods
]

{ #category : 'private - history' }
DSRecordHistory >> collectTimeDiscrepancies [
	"Returns a dictionary which contains all delta between two records above than 5s"

	| time previousRecord copyOfRecords deltas |
	copyOfRecords := records deepCopy.
	time := 0.
	deltas := OrderedCollection new.
	previousRecord := copyOfRecords first.
	copyOfRecords do: [ :record |
			| delta |
			delta := record dateTime asSeconds - previousRecord dateTime asSeconds.
			time := time + delta.
			delta > 5 ifTrue: [
					deltas add: {
							previousRecord .
							record } -> delta asSeconds ].
			previousRecord := record ].
	
	^ deltas
]

{ #category : 'API-history' }
DSRecordHistory >> countDebugActions [

	^ self debugPointAdds + self debugPointRemoved + self executedCode
	  + self methodsAdded + self methodsModified + self methodsRemoved
	  + self numberOfSteps
]

{ #category : 'accessing' }
DSRecordHistory >> dateTime [
	^records first dateTime
]

{ #category : 'API-history' }
DSRecordHistory >> debugPointAdds [

	^ (self debugPointEvents: DebugPointAdded name) size
]

{ #category : 'API-history' }
DSRecordHistory >> debugPointAnalysisMap [

	| report |
	report := Dictionary new.
	(self allRecordsOfKind: DSAbstractDebugPointEventRecord) do: [ :debugPoint |
			(report at: debugPoint target ifAbsentPut: [
					 DSDebugPointReport new
						 method: debugPoint target;
						 yourself ]) add: debugPoint ].
	^ report
]

{ #category : 'private - history' }
DSRecordHistory >> debugPointEvents [

	^ self records select: [ :r | (r isKindOf: DSAbstractDebugPointEventRecord)]
]

{ #category : 'private - history' }
DSRecordHistory >> debugPointEvents: aDebugPointEventName [

	^ self debugPointEvents select: [ :bpEvent | 
		  bpEvent eventName = aDebugPointEventName ]
]

{ #category : 'API-history' }
DSRecordHistory >> debugPointHit [

	^ (self debugPointEvents: DebugPointHit name) size
]

{ #category : 'API-history' }
DSRecordHistory >> debugPointRemoved [

	^ (self debugPointEvents: DebugPointRemoved name) size
]

{ #category : 'private - history' }
DSRecordHistory >> detectTimeDiscrepancies [
	"Returns the sum of all breaks between two records which lasted more than 1 minute"

	| currentRecord totalDelta |
	totalDelta := 0.
	currentRecord := records first.
	records do: [ :r |
			| delta |
			((r isKindOf: DSWindowOpenedRecord) and: [ 'Finish task *' match: r windowName asString ]) ifTrue: [ ^ totalDelta ].
			delta := r dateTime asSeconds - currentRecord dateTime asSeconds.
			delta > 60 ifTrue: [ totalDelta := totalDelta + delta ].
			currentRecord := r ].
	^ totalDelta
]

{ #category : 'private - history' }
DSRecordHistory >> estimateSourceEventOf: aDSDebuggerOpeningRecord from: aRecordList [

	| eventIndex |
	eventIndex := aRecordList indexOf: aDSDebuggerOpeningRecord.

	eventIndex = 1 ifTrue: [ ^ nil ].

	(self
		 findSourceEventLike: self primarySourcesOfDebuggerOpenings
		 forRecord: aDSDebuggerOpeningRecord
		 in: aRecordList) ifNotNil: [ :sourceEvent | ^ sourceEvent ].

	(self
		 findSourceEventLike: self secondarySourcesOfDebuggerOpenings
		 forRecord: aDSDebuggerOpeningRecord
		 in: aRecordList) ifNotNil: [ :sourceEvent | ^ sourceEvent ].

	^ aRecordList at: eventIndex - 1
]

{ #category : 'API-history' }
DSRecordHistory >> eventsAfter: aDateAndTime [ 
	^records select:[:e| e dateTime > aDateAndTime]
]

{ #category : 'API-history' }
DSRecordHistory >> eventsBefore: aDateAndTime [ 
	^records select:[:e| e dateTime < aDateAndTime]
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
DSRecordHistory >> filteredWindowJumps: aListOfWindowJumps [

	filteredWindowJumps := aListOfWindowJumps
]

{ #category : 'accessing' }
DSRecordHistory >> filteredWindows [

	^ filteredWindows
]

{ #category : 'accessing' }
DSRecordHistory >> filteredWindows: aCollectionOfWindows [

	filteredWindows := aCollectionOfWindows
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
	"Process all records, when the windowId is nil change it by the predecessor one. If there is no predecessor, put -1."

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
DSRecordHistory >> fixWindowRecordKeysNames [

	windowNames keysAndValuesDo: [ :id :name | 
		(self findWindowRecordKeyForID: id) windowName: name ]
]

{ #category : 'API-history' }
DSRecordHistory >> getSumOfScrollingPeriods [

	| scrollingPeriods |
	scrollingPeriods := self collectScrollingPeriods.
	scrollingPeriods := scrollingPeriods collect: [ :association |
		                    association key second - association key first -> association value ].

	scrollingPeriods := scrollingPeriods groupedBy: [ :association | association value ].

	scrollingPeriods := scrollingPeriods collect: [ :array | array collect: [ :association | association key ] ].

	^ scrollingPeriods collect: [ :value | value sum ]
]

{ #category : 'API-history' }
DSRecordHistory >> haltAnalysisMap [

	| report |
	report := Dictionary new.
	(self allRecordsOfKind: DSAbstractHaltRecord) do: [ :haltRecord |
		(report at: haltRecord method ifAbsentPut: [
			 DSHaltReport new
				 method: haltRecord method;
				 yourself ]) add: haltRecord ].
	^ report
]

{ #category : 'private - history' }
DSRecordHistory >> mergeContinuousEvents [

	| newRecords merge record |
	newRecords := OrderedCollection new.
	merge := OrderedCollection new.
	record := records first.
	merge add: record.
	(records copy asOrderedCollection
		 removeFirst;
		 yourself) do: [ :next |
			record class = next class ifFalse: [
					newRecords add: merge.
					merge := OrderedCollection new ].
			merge add: next.
			record := next ].
	newRecords add: merge.
	^ newRecords
]

{ #category : 'private - history' }
DSRecordHistory >> mergeFilteredWindowJumps [

	| currentJump |
	mergedWindowJumps := OrderedCollection new.
	currentJump := filteredWindowJumps first.

	[ currentJump notNil ] whileTrue: [
			(currentJump next isNotNil and: [ currentJump window = currentJump next window ])
				ifTrue: [ currentJump := currentJump mergeWith: currentJump next ]
				ifFalse: [
						mergedWindowJumps ifNotEmpty: [ currentJump previous: mergedWindowJumps last ].
						mergedWindowJumps add: currentJump.
						currentJump := currentJump next ] ]
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

	^ (self allRecordsOfKind: DSAbstractDebuggerActionRecord) size
]

{ #category : 'private - history' }
DSRecordHistory >> primarySourcesOfDebuggerOpenings [

	^ ({
		   DSAbstractDebugPointEventRecord.
			DSDebugItRecord.
		   DSHaltHitRecord.
		   DSUnhandledExceptionRecord } collect: [ :element | element withAllSubclasses ]) flattened
]

{ #category : 'initialization' }
DSRecordHistory >> processRecords: anArrayOfRecords [
	"Build the history from an array of records"

	"events with window id equals to 0 are automatic events triggered while opening a spec presenter while the window is not already open -> noise "
	records := (anArrayOfRecords reject: [ :e | #( 0 ) includes: e windowId ]). 
	
	"Transform raw events to model events"
	(self allRecordsOfKind: DSAbstractDebugPointEventRecord) do: #asDebugPointRecord. 
	
	"Detect if we're in a specific task"
	(records first isKindOf: DSStartTaskRecord) ifTrue: [ taskName := records first taskName ]. 
	
	"Windows"
	self buildWindowHistory.
	self buildWindows.
	self buildWindowJumps.	
	filteredWindowJumps ifNotEmpty: [ self mergeFilteredWindowJumps ].
	
	"Check data consistency (raises a warning that can be proceeded)"
	self validateWindows.

	^ self
]

{ #category : 'private - history' }
DSRecordHistory >> reconstructSourcesOfDebuggerOpenings [

	| sortedDebuggerWindows recordsCopy |
	sortedDebuggerWindows := (windows select: [ :w | w isDebugger ]) sort: [ :d1 :d2 |
		                         d1 events first dateTime < d2 events first dateTime ].

	recordsCopy := records copy asOrderedCollection.

	sortedDebuggerWindows do: [ :w |
			| sourceEvent |
			sourceEvent := self estimateSourceEventOf: w events first from: recordsCopy.
			recordsCopy removeFirst: (recordsCopy indexOf: w events first).
			w sourceEvent: sourceEvent ]
]

{ #category : 'API-history' }
DSRecordHistory >> reconstructWindowsToolInfo [

	| toolInfos validWindows |
	toolInfos := Dictionary new.

	records do: [ :record |
			(record class = DSMouseEnterWindowRecord and: [ record toolInfo isNotNil ]) ifTrue: [
				toolInfos at: record toolInfo windowIdentityHash ifAbsentPut: record toolInfo ] ].

	validWindows := windows groupedBy: #windowId.
	validWindows
		removeKey: -1 ifAbsent: [ ];
		removeKey: nil ifAbsent: [ ].
	
	validWindows keysAndValuesDo: [ :id :col |
			id ifNotNil: [
					| window |
					window := col first.
					window toolInfo: (toolInfos at: id ifAbsent: [ nil ]) ] ].
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

{ #category : 'private - history' }
DSRecordHistory >> secondarySourcesOfDebuggerOpenings [

	^ ({
		   DSCodeActionRecord.
		   DSAbstractDebuggerActionRecord } collect: [ :c | c withAllSubclasses ]) flattened
]

{ #category : 'accessing' }
DSRecordHistory >> startTime [

	^ records first dateTime asTime
]

{ #category : 'accessing' }
DSRecordHistory >> stopTime [
	^records last dateTime asTime
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
DSRecordHistory >> toolInfosFor: aWindowId [

	^ ((windows groupedBy: #windowId) at: aWindowId ifAbsent: [ ^ nil ])
		  first toolInfo
]

{ #category : 'accessing' }
DSRecordHistory >> usedTools [

	| allTools filteredTools |
	allTools := ((windows reject: [ :w |
		              w toolInfo isNil or: [ w toolInfo isEmpty ] ])
		             collect: [ :w | w toolInfo first toolClass ])
		            asSet.
	filteredTools := OrderedCollection new.
	allTools do: [ :tName |
		(#( 'ClyFullBrowserMorph' 'ClyQueryBrowserMorph' ) includes: tName)
			ifTrue: [
				tName = 'ClyFullBrowserMorph'
					ifTrue: [ filteredTools add: 'Browser' ]
					ifFalse: [ filteredTools addAll: #( 'Senders' 'Implementors' ) ] ]
			ifFalse: [
				| substrings |
				substrings := tName normalizeCamelCase substrings
					              asOrderedCollection.
				substrings first = 'St' ifTrue: [ substrings removeFirst ].
				substrings last = 'Presenter' ifTrue: [ substrings removeLast ].
				filteredTools add:
					(String streamContents: [ :str |
						 substrings do: [ :s | str << s ] ]) ] ].
	filteredTools add: 'Github (read)'.
	filteredTools add: 'Github (diff)'.
	filteredTools add: 'Task description'.
	^ filteredTools
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
DSRecordHistory >> validateWindows [
	"Validates that each windows starts by a window entering or opening event, finishes by a window closing or leaving event, and that every event contained in the window happened between the opening event timestamp and the closing even timestamp"

	| erroneousWindows |
	erroneousWindows := Dictionary new.

	windows do: [ :window | "erroneousWindows ifNotEmpty: [
		Warning signal: (String streamContents: [ :str |
				 str << erroneousWindows size printString.
				 str space.
				 str
				 <<
				 'potential sequence problem found in windows. This is just an information, you can proceed.' ]) ]"
			| firstEvent lastEvent |
			firstEvent := window events first.
			lastEvent := window events last.

			({
				 DSWindowOpenedRecord.
				 DSWindowActivatedRecord.
				 DSMouseEnterWindowRecord } includes: firstEvent class) ifFalse: [
				(erroneousWindows at: window ifAbsentPut: [ OrderedCollection new ]) add: #opening -> firstEvent ].

			({
				 DSWindowClosedRecord.
				 DSMouseLeaveWindowRecord } includes: lastEvent class) ifFalse: [
				(erroneousWindows at: window ifAbsentPut: [ OrderedCollection new ]) add: #closing -> lastEvent ].

			(erroneousWindows at: window ifAbsentPut: [ OrderedCollection new ]) addAll:
				(window events reject: [ :event | event dateTime between: firstEvent dateTime and: lastEvent dateTime ]) ].

	^ erroneousWindows
]

{ #category : 'accessing' }
DSRecordHistory >> windowJumps [

	^ windowJumps
]

{ #category : 'accessing' }
DSRecordHistory >> windowJumps: aCollectionOfPeriods [

	windowJumps := aCollectionOfPeriods
]

{ #category : 'accessing' }
DSRecordHistory >> windowNames [

	^ windowNames 
]

{ #category : 'accessing' }
DSRecordHistory >> windowNames: aDictionary [

	windowNames := aDictionary 
]

{ #category : 'accessing' }
DSRecordHistory >> windows [
	^ windows
]

{ #category : 'accessing' }
DSRecordHistory >> windows: aCollectionOfWindows [

	windows := aCollectionOfWindows
]

{ #category : 'accessing' }
DSRecordHistory >> windowsHistory [

	^ windowsHistory ifNil: [ windowsHistory := IdentityDictionary new ]
]

{ #category : 'accessing' }
DSRecordHistory >> windowsHistory: anObject [

	windowsHistory := anObject
]

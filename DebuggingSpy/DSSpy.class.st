"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#classVars : [
		'monitor'
	],
	#classInstVars : [
		'logDir'
	],
	#category : #'DebuggingSpy-Instrumentation'
}

{ #category : #'mutual exclusion' }
DSSpy class >> critical: aBlock [
	self monitor critical: aBlock
]

{ #category : #logging }
DSSpy class >> dateTimeString [
	^'[' , DateAndTime now asString , ']:'
]

{ #category : #'events - breakpoints' }
DSSpy class >> indexesOfHaltNodesIn: aMethod [

	| haltNodes |
	haltNodes := aMethod ast allChildren select: [ :n | n isHaltNode ].
	^ haltNodes collect: [ :hn | hn selector -> (hn start to: hn stop) ]
]

{ #category : #logging }
DSSpy class >> log: elements key: key [
	| log |
	log := key , ':', self dateTimeString, elements printString, ':END_', key, ':'.
	log crTrace.
	self critical: [ self logToFile: log ]
]

{ #category : #helpers }
DSSpy class >> logDir: aString [
	logDir := aString asFileReference.
	logDir ensureCreateDirectory
]

{ #category : #helpers }
DSSpy class >> logFileReference [
	| fname fr |
	fname := SessionManager default currentSession id asString.
	fr := logDir
		ifNil: [ fname asFileReference ]
		ifNotNil: [ logDir / fname ].
	fr ensureCreateFile.
	^ fr
]

{ #category : #logging }
DSSpy class >> logInspectorTabChange: selectedTab [
	[ 
	|anArrayOfMorphs |
	anArrayOfMorphs :=  selectedTab label allMorphs.
	self
		log: (self printGLMStringMorphs: anArrayOfMorphs)
		key: #INSPECTOR_TAB_SELECTION ]
		on: Error
		do: [ self log: #ERROR key: #INSPECTOR_TAB_SELECTION ]
]

{ #category : #helpers }
DSSpy class >> logToFile: aString [
	|str|
	str := self stream.
	str setToEnd.
	str crlf.
	str nextPutAll: aString.	
	str close
]

{ #category : #'events - windows' }
DSSpy class >> logWindowActivated: anEvent [

	[ DSWindowActivatedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_ACTIVATED ]
]

{ #category : #'events - windows' }
DSSpy class >> logWindowClosed: anEvent [
	[ DSWindowClosedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_CLOSED ]
]

{ #category : #'events - windows' }
DSSpy class >> logWindowOpened: anEvent [
	| window |
	window := anEvent window.
	[ DSWindowOpenedRecord for: anEvent ]
		on: Error
		do: [ self log: #ERROR key: #WINDOW_OPENED ].
	window announcer
		when: WindowActivated
		send: #logWindowActivated:
		to: self.
	window announcer when: WindowClosed send: #logWindowClosed: to: self
]

{ #category : #'events - methods' }
DSSpy class >> methodAdded: evt [

	[ 
	| method |
	method := evt method.
	DSMethodAddedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInAddedMethod: method ] ]
		on: Error
		do: [ :e | self log: #ERROR key: #METHOD_ADDED ]
]

{ #category : #'events - methods' }
DSSpy class >> methodChanged: evt [

	[ 
	| oldMethod newMethod |
	oldMethod := evt oldMethod.
	newMethod := evt method.

	DSMethodModifiedRecord for: newMethod.

	(oldMethod containsHalt and: [ newMethod containsHalt not ]) ifTrue: [ 
		self recordHaltInRemovedMethod: oldMethod ].
	(oldMethod containsHalt not and: [ newMethod containsHalt ]) ifTrue: [ 
		self recordHaltInAddedMethod: newMethod ].
	(oldMethod containsHalt and: [ newMethod containsHalt ]) ifTrue: [ 
		self recordHaltInMethod: oldMethod modifiedBy: newMethod ] ]
		on: Error
		do: [ self log: #ERROR key: #METHOD_MODIFIED ]
]

{ #category : #'events - methods' }
DSSpy class >> methodRemoved: evt [

	[ 
	| method |
	method := evt method.
	DSMethodRemovedRecord for: method.
	method containsHalt ifTrue: [ self recordHaltInRemovedMethod: method ] ]
		on: Error
		do: [ self log: #ERROR key: #METHOD_REMOVED ]
]

{ #category : #accessing }
DSSpy class >> monitor [
	^monitor ifNil:[monitor := Monitor new]
]

{ #category : #logging }
DSSpy class >> printGLMStringMorphs: anArrayOfMorphs [
	| str |
	str := WriteStream on: String new.
	anArrayOfMorphs
		do: [ :m | 
			(m isKindOf: GLMStringBrick)
				ifTrue: [ str << m text asString.
					str << ' ' ] ].
	^ str contents
]

{ #category : #logging }
DSSpy class >> printStringMorphs: anArrayOfMorphs [
	| str |
	str := WriteStream on: String new.
	anArrayOfMorphs
		do: [ :m | 
			((m isKindOf: StringMorph) and: [ m contents ~= '...' ])
				ifTrue: [ str << m contents asString.
					str << ' ' ] ].
	^ str contents
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordBreakpointEvent: aBreakpointEvent [
	^aBreakpointEvent recordBreakpoint 
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordHaltInAddedMethod: method [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: method.
	record := DSHaltChangeRecord for: DSHaltChangeRecord add.
	record haltData: nodesSelectorsWithIndexes.
	record method: method name
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordHaltInMethod: oldMethod modifiedBy: newMethod [

	| oldHalts newHalts record |
	oldHalts := self indexesOfHaltNodesIn: oldMethod.
	newHalts := self indexesOfHaltNodesIn: newMethod.

	(oldHalts size = newHalts size and: [ 
		 oldHalts allSatisfy: [ :data | newHalts includes: data ] ]) 
		ifTrue: [ ^ self ].

	record := DSHaltChangeRecord for: DSHaltChangeRecord modify.
	record haltData: newHalts.
	record method: newMethod name
]

{ #category : #'events - breakpoints' }
DSSpy class >> recordHaltInRemovedMethod: oldMethod [
	|nodesSelectorsWithIndexes record|
	nodesSelectorsWithIndexes := self indexesOfHaltNodesIn: oldMethod.
	record := DSHaltChangeRecord for: DSHaltChangeRecord remove.
	record haltData: nodesSelectorsWithIndexes.
	record method: oldMethod name
]

{ #category : #helpers }
DSSpy class >> stream [
	^ self logFileReference writeStream
]

{ #category : #helpers }
DSSpy class >> windowName: win [
	|label|	
	label := [win labelString ] on: Error do:['window '].
	^label, ' (', win hash printString, ')'
]

{ #category : #helpers }
DSSpy class >> windowNameFromEvent: anEvent [
	|win|
	win := anEvent window.
	^self windowName: win
]

"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#category : #DebuggingSpy
}

{ #category : #events }
DSSpy class >> breakpointEvent: aBreakpointEvent [
	aBreakpointEvent logBreakpointEventOn: self
]

{ #category : #logging }
DSSpy class >> log: e [
	self halt.
	e crTrace
]

{ #category : #logging }
DSSpy class >> log: elements key: key [
	|log|
	log :=  '[', Time now asSeconds printString, '] ', key , ' -> ' , elements printString.
	Transcript show: log.
	Transcript cr.
	self logToFile: log
]

{ #category : #logging }
DSSpy class >> logInspectorTabChange: anArrayOfMorphs [
	[ self
		log: (self printGLMStringMorphs: anArrayOfMorphs)
		key: #INSPECTOR_TAB_SELECTION ]
		on: Error
		do: [ self log: #ERROR key: #INSPECTOR_TAB_SELECTION ]
]

{ #category : #logging }
DSSpy class >> logMouseEnter: anArrayOfMorphs [
	[ self
		log: (self printStringMorphs: anArrayOfMorphs)
		key: #MOUSE_OVER ]
		on: Error
		do: [ self log: #ERROR key: #MOUSE_OVER ]
]

{ #category : #helpers }
DSSpy class >> logToFile: aString [
	|str|
	str := self stream.
	str setToEnd.
	str nextPutAll: aString.
	str cr.
	str close 
]

{ #category : #events }
DSSpy class >> logWindowActivated: anEvent [

	self log: (self windowNameFromEvent: anEvent) key: #WINDOW_ACTIVATED
]

{ #category : #events }
DSSpy class >> logWindowClosed: anEvent [

	self log: (self windowNameFromEvent: anEvent) key: #WINDOW_CLOSED
]

{ #category : #events }
DSSpy class >> logWindowOpened: anEvent [
	| window |
	window := anEvent window.
	self log: (self windowNameFromEvent: anEvent) key: #WINDOW_OPENED.
	window announcer
		when: WindowActivated
		send: #logWindowActivated:
		to: self.
	window announcer
		when: WindowClosed
		send: #logWindowClosed:
		to: self
]

{ #category : #events }
DSSpy class >> methodAdded: evt [
	self log: evt method key: #METHOD_ADDED
]

{ #category : #events }
DSSpy class >> methodChanged: evt [
	self log: evt method key: #METHOD_MODIFIED
]

{ #category : #events }
DSSpy class >> methodRemoved: evt [
	self log: evt method key: #METHOD_REMOVED
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

{ #category : #helpers }
DSSpy class >> stream [
	|rf|
	rf := 	'test' asFileReference. "do a lazy accessor"
	rf ensureCreateFile.
	^rf writeStream
]

{ #category : #events }
DSSpy class >> update: aBreakpointEvent [

	[ self breakpointEvent: aBreakpointEvent ] on: Error do:[self log: #ERROR key: #BREAKPOINT_EVENT]
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

"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#category : #DebuggingSpy
}

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

{ #category : #helpers }
DSSpy class >> stream [
	|rf|
	rf := 	'test' asFileReference. "do a lazy accessor"
	rf ensureCreateFile.
	^rf writeStream
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

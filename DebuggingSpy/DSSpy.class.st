"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#category : #DebuggingSpy
}

{ #category : #logging }
DSSpy class >> log: elements key: key [
	Transcript show: '[', Time now asSeconds printString, '] ', key , ' -> ' , elements printString.
	Transcript cr
]

{ #category : #'as yet unclassified' }
DSSpy class >> logMouseDownEvent: anEvent [
	(anEvent handler isKindOf: SystemWindow)
		ifTrue: [ anEvent handler labelString crTrace ]
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
		to: self.
	"window announcer
		when: MouseButtonEvent
		send: #logMouseDownEvent:
		to: self"
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
DSSpy class >> windowNameFromEvent: anEvent [
	|win label|
	win := anEvent window.
	label := [win labelString ] on: Error do:['window '].
	^label, ' (', win hash printString, ')'
]

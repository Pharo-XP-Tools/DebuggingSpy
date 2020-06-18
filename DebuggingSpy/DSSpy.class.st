"
I collect spy informations
"
Class {
	#name : #DSSpy,
	#superclass : #Object,
	#category : #DebuggingSpy
}

{ #category : #'as yet unclassified' }
DSSpy class >> log: elements key: key [
	Transcript show: '[', Time now asSeconds printString, '] ', key , ' -> ' , elements printString.
	Transcript cr
]

{ #category : #'as yet unclassified' }
DSSpy class >> logMouseDownEvent: anEvent [
	(anEvent handler isKindOf: SystemWindow)
		ifTrue: [ anEvent handler labelString crTrace ]
]

{ #category : #'as yet unclassified' }
DSSpy class >> logWindowActivated: anEvent [
	| window |
	window := anEvent window.
	window labelString crTrace
]

{ #category : #'as yet unclassified' }
DSSpy class >> logWindowOpenEvent: anEvent [
	| window |
	window := anEvent window.
	window labelString crTrace.
	window announcer
		when: WindowActivated
		send: #logWindowActivated:
		to: self.
	window announcer
		when: MouseButtonEvent
		send: #logMouseDownEvent:
		to: self
]

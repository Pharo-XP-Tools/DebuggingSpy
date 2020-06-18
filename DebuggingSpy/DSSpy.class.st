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
	Transcript show: key , ' -> ' , elements printString.
	Transcript cr
]

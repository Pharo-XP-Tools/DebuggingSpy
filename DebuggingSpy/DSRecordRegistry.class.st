"
For now I am a dumb registry to simply record all events in an ordered collection
"
Class {
	#name : #DSRecordRegistry,
	#superclass : #Object,
	#instVars : [
		'records'
	],
	#classVars : [
		'Current'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSRecordRegistry class >> current [
	^Current ifNil:[Current := self new]
]

{ #category : #initialization }
DSRecordRegistry >> addRecord: aRecord [
	records add: aRecord
]

{ #category : #initialization }
DSRecordRegistry >> initialize [
	records := OrderedCollection new
]

{ #category : #accessing }
DSRecordRegistry >> records [

	^ records
]

{ #category : #initialization }
DSRecordRegistry >> reset [
	records removeAll.
	DSSpy resetSpy
]

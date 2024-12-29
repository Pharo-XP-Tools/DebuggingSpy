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
	#classInstVars : [
		'autoSerialize'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSRecordRegistry class >> autoSerialize [

	^ autoSerialize ifNil: [ autoSerialize := false ]
]

{ #category : #accessing }
DSRecordRegistry class >> autoSerialize: anObject [

	autoSerialize := anObject
]

{ #category : #accessing }
DSRecordRegistry class >> current [
	^Current ifNil:[Current := self new]
]

{ #category : #private }
DSRecordRegistry class >> log: aDSRecord [

	self autoSerialize ifFalse: [ ^ self ].
	DSSpy serialize: aDSRecord
]

{ #category : #private }
DSRecordRegistry class >> serialize: aDSRecord [

	self autoSerialize ifFalse: [ ^ self ].
	DSSpy serialize: aDSRecord
]

{ #category : #initialization }
DSRecordRegistry >> addRecord: aRecord [
	self assert: aRecord dateTime notNil.
	records add: aRecord.
	self class log: aRecord.
	self flag: 'Add debug code here to see what is traced'.
	"aRecord crTrace"
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

Class {
	#name : #DSRecordRegistryTest,
	#superclass : #TestCase,
	#instVars : [
		'record'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #running }
DSRecordRegistryTest >> tearDown [

	DSRecordRegistry autoSerialize: nil.
	super tearDown
]

{ #category : #tests }
DSRecordRegistryTest >> testAutoSerialize [
	self deny: DSRecordRegistry autoSerialize 
]

{ #category : #tests }
DSRecordRegistryTest >> testAutoSerializeRecord [
	|materializedRecord|
	DSSpy loggingFileReference ensureDelete.
	DSRecordRegistry autoSerialize: true.
	record := DSLoggingErrorRecord for: #TEST.
	materializedRecord := (DSSpy materialize: DSSpy loggingFileReference) first.
	self assert: materializedRecord dateTime equals: record dateTime.
	self assert: materializedRecord event equals: record event.
	self assert: materializedRecord class equals: record class
]

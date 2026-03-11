Class {
	#name : 'DSAnonymizerTest',
	#superclass : 'TestCase',
	#instVars : [
		'record'
	],
	#category : 'DebuggingSpy-Anonymizer-tests',
	#package : 'DebuggingSpy-Anonymizer',
	#tag : 'tests'
}

{ #category : 'running' }
DSAnonymizerTest >> setUp [
	super setUp.
	record := DSWindowOpenedRecord example

	"Put here a common initialization logic for tests"
]

{ #category : 'tests' }
DSAnonymizerTest >> testRecordAnonymize [
	record anonymize.
	self assert: ((record class allSlots collect: [ :s | s read: record ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSAnonymizerTest >> testRecordIsNotAnonymous [

	self assert: ((record class allSlots collect: [ :s | s read: record ]) allSatisfy: #notNil)
]

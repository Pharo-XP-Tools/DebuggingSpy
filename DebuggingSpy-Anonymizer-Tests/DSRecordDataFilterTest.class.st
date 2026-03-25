Class {
	#name : 'DSRecordDataFilterTest',
	#superclass : 'TestCase',
	#instVars : [
		'filter'
	],
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'helpers' }
DSRecordDataFilterTest >> recordExample [
	"Returns an exemple of record used to test filtering features."

	^ DSTestFilterRecord new
		  first: 1;
		  second: 'second value';
		  yourself
]

{ #category : 'running' }
DSRecordDataFilterTest >> setUp [

	super setUp.
	filter := DSRecordDataFilter new
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testAddTransformation [

	| block |
	block := [ :a | nil ].
	filter transform: #test with: block.
	self assert: (filter operations at: 'test') equals: block
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testApplyOn [

	| record |
	record := self recordExample.
	self deny: (filter applyOn: record) identityHash equals: record identityHash
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testFilteringASlot [

	| filteredRecord |
	filter with: #first.
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first equals: 1.
	self assert: filteredRecord second isNil
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testFilteringAllSlots [

	| filteredRecord |
	filteredRecord := filter applyOn: self recordExample.
	self assert: ((filteredRecord class allSlots collect: [ :s | s read: filteredRecord ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testHash [

	| filteredRecord |
	filter hash: #first.
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first class equals: SmallInteger
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testProcessRecordsWith [

	| records |
	records := Set new
		           add: self recordExample;
		           add: self recordExample;
		           add: self recordExample;
		           yourself.
		
	self assert: ((DSRecordDataFilter processRecords: records with: #filterFirstValue) allSatisfy: [ :aRecord |
			 aRecord first isNil and: aRecord second = 'second value' ])
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testTransformWith [

	| filteredRecord |
	filter transform: #first with: [ :aNumber | aNumber * 2 ].
	filter transform: #second with: [ :aString | aString asUppercase ].
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first equals: 2.
	self assert: filteredRecord second equals: 'SECOND VALUE'
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testVerifySlotDuplicationFor [

	| block |
	block := [ :a | nil ].
	filter transform: #test with: block.
	self should: [ filter transform: #test with: block ] raise: Exception description: 'A slot cannot be transformed twice.'
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testWith [

	filter with: #first.
	self assert: ((filter operations at: 'first') value: 5) equals: 5.
	self assert: (filter applyOn: self recordExample) first equals: 1
]

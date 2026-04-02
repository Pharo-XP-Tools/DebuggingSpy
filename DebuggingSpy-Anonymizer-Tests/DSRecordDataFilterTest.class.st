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

	| oldRecord record filteredRecord |
	filter with: #first.
	record := self recordExample.
	oldRecord := record copy.
	filteredRecord := filter applyOn: record.

	self deny: filteredRecord identityHash equals: record identityHash.
	self assert: filteredRecord first equals: record first.
	self assert: filteredRecord second isNil.

	self assert:
		(oldRecord class allSlots allSatisfy: [ :slot | (record readSlotNamed: slot name) = (oldRecord readSlotNamed: slot name) ])
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

	self assert: (filter operations at: 'first') class equals: CleanBlockClosure.

	self assert: filteredRecord first class equals: SmallInteger.
	self deny: filteredRecord first equals: 1
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testProcessRecordsWith [

	| records newRecords |
	records := {
		           (DSTestFilterRecord new
			            first: 1;
			            second: 'second value').
		           (DSTestFilterRecord new
			            first: 2;
			            second: 'another second value').
		           (DSTestFilterRecord new
			            first: 3;
			            second: 'another one') } asOrderedCollection.

	newRecords := DSRecordDataFilter processRecords: records with: #filterFirstValue.

	self assert: (newRecords allSatisfy: [ :aRecord | aRecord first isNil ]).
	self assert: newRecords first second equals: 'second value'.
	self assert: newRecords second second equals: 'another second value'.
	self assert: newRecords last second equals: 'another one'
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testTransformWith [

	| filteredRecord |
	filter transform: #first with: [ :aNumber | aNumber * 2 ].
	filter transform: #second with: [ :aString | aString asUppercase ].
	filteredRecord := filter applyOn: self recordExample.

	self assert: (filter operations at: 'first') class equals: CleanBlockClosure.
	self assert: (filter operations at: 'second') class equals: CleanBlockClosure.

	self assert: filteredRecord first equals: 2.
	self assert: filteredRecord second equals: 'SECOND VALUE'
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testWith [

	filter with: #first.
	self assert: (filter operations at: 'first') class equals: CleanBlockClosure.

	self assert: (filter applyOn: self recordExample) first equals: 1
]

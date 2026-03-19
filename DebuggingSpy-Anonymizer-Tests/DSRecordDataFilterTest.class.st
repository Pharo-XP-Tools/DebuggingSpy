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

	^ DSTestRecord new
		  first: 'first value';
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
DSRecordDataFilterTest >> testEmptyFilter [

	self assert: filter class equals: DSRecordDataFilter.
	self assert: filter operations isEmpty
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testFilteringASlot [

	| filteredRecord |
	filter with: #first.
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first equals: 'first value'.
	self assert: filteredRecord second isNil
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testFilteringAllSlots [

	| filteredRecord |
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.
	self assert: ((filteredRecord class allSlots collect: [ :s | s read: filteredRecord ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testHashTransformation [

	| filteredRecord |
	filter hash: #first.
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first class equals: SmallInteger
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testIncludingSymbol [

	filter with: #test.
	self assert: ((filter operations at: 'test') value: 5) equals: 5
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testTransformation [

	| filteredRecord |
	filter transform: #first with: [ :aValue | 42 ].
	filteredRecord := filter applyOn: self recordExample.

	self assert: filteredRecord first equals: 42
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testVerifySlotDuplication [

	| block |
	block := [ :a | nil ].
	filter transform: #test with: block.
	self should: [ filter transform: #test with: block ] raise: Exception description: 'A slot cannot be transformed twice.'
]

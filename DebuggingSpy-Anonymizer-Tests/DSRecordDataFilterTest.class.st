Class {
	#name : 'DSRecordDataFilterTest',
	#superclass : 'TestCase',
	#instVars : [
		'filter'
	],
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'tests' }
DSRecordDataFilterTest >> DSRecordDataFilter [
]

{ #category : 'accessing' }
DSRecordDataFilterTest >> filterClass [

	^ DSRecordDataFilter
]

{ #category : 'running' }
DSRecordDataFilterTest >> setUp [

	super setUp.
	filter := self filterClass new
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
	filter with: #uuid.
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.

	self deny: filteredRecord uuid isNil.
	self assert:
		((filteredRecord class allSlots reject: [ :slot | slot name = 'uuid' ] thenCollect: [ :s | s read: filteredRecord ])
			 allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testFilteringAllSlots [

	| filteredRecord |
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.
	self assert: ((filteredRecord class allSlots collect: [ :s | s read: filteredRecord ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testIncludingSymbol [

	filter with: #test.
	self assert: ((filter operations at: 'test') value: 5) equals: 5
]

{ #category : 'tests' }
DSRecordDataFilterTest >> testVerifySlotDuplication [

	| block |
	block := [ :a | nil ].
	filter transform: #test with: block.
	self should: [ filter transform: #test with: block ] raise: Exception description: 'A slot cannot be transformed twice.'
]

Class {
	#name : 'DSRecordIncludeFilterTest',
	#superclass : 'DSRecordDataFilterTest',
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'accessing' }
DSRecordIncludeFilterTest >> filterClass [

	^ DSRecordIncludeFilter
]

{ #category : 'tests' }
DSRecordIncludeFilterTest >> testEmptyFilter [

	self assert: filter class equals: DSRecordIncludeFilter.
	self assert: filter operations isEmpty
]

{ #category : 'tests' }
DSRecordIncludeFilterTest >> testFilteringASlot [

	| filteredRecord |
	filter with: #uuid.
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.

	self deny: filteredRecord uuid isNil.
	self assert:
		((filteredRecord class allSlots reject: [ :slot | slot name = 'uuid' ] thenCollect: [ :s | s read: filteredRecord ])
			 allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordIncludeFilterTest >> testFilteringAllSlots [

	| filteredRecord |
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.
	self assert: ((filteredRecord class allSlots collect: [ :s | s read: filteredRecord ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordIncludeFilterTest >> testIncludingSymbol [

	filter with: #test.
	self assert: ((filter operations at: 'test') value: 5) equals: 5
]

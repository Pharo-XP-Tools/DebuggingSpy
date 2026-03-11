Class {
	#name : 'DSRecordExcludeFilterTest',
	#superclass : 'DSRecordDataFilterTest',
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'accessing' }
DSRecordExcludeFilterTest >> filterClass [

	^ DSRecordExcludeFilter
]

{ #category : 'tests' }
DSRecordExcludeFilterTest >> testEmptyFilter [

	self assert: filter class equals: DSRecordExcludeFilter.
	self assert: filter operations isEmpty
]

{ #category : 'tests' }
DSRecordExcludeFilterTest >> testExcludingASlot [

	| filteredRecord |
	filter without: #uuid.
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.

	self assert: filteredRecord uuid isNil.
	self deny:
		((filteredRecord class allSlots reject: [ :slot | slot name = 'uuid' ] thenCollect: [ :s | s read: filteredRecord ])
			 allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordExcludeFilterTest >> testExcludingNoSlot [

	| filteredRecord |
	filteredRecord := filter applyOn: DSWindowOpenedRecord example.
	self deny: ((filteredRecord class allSlots collect: [ :s | s read: filteredRecord ]) allSatisfy: #isNil)
]

{ #category : 'tests' }
DSRecordExcludeFilterTest >> testExcludingSymbol [

	filter without: #test.
	self assert: ((filter operations at: 'test') value: 5) equals: nil
]

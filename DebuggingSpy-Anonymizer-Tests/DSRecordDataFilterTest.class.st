Class {
	#name : 'DSRecordDataFilterTest',
	#superclass : 'TestCase',
	#instVars : [
		'filter'
	],
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

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
DSRecordDataFilterTest >> testVerifySlotDuplication [

	| block |
	block := [ :a | nil ].
	filter transform: #test with: block.
	self should: [ filter transform: #test with: block ] raise: Exception description: 'A slot cannot be transformed twice.'
]

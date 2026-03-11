"
I am a class that represents a data filter for the Debugging Spy records.
My api provides : 
- #with that ensures that the specified slot will be deepcopied into the new record.
- #without that ensures that the specified slot will be nil.
- #transform that permits to define a specific transformation for a slot.
"
Class {
	#name : 'DSRecordDataFilter',
	#superclass : 'Object',
	#instVars : [
		'operations'
	],
	#category : 'DebuggingSpy-Anonymizer-filters',
	#package : 'DebuggingSpy-Anonymizer',
	#tag : 'filters'
}

{ #category : 'filtering' }
DSRecordDataFilter >> applyOn: aRecord [
	"Applies the filter on a deep copy of the specified record."

	self subclassResponsibility
]

{ #category : 'accessing' }
DSRecordDataFilter >> getRecordCopyOf: aRecord [
	"Returns a deep copy of the specified record."

	^ aRecord deepCopy
]

{ #category : 'initialization' }
DSRecordDataFilter >> initialize [

	super initialize.
	operations := SmallDictionary new
]

{ #category : 'filtering' }
DSRecordDataFilter >> transform: aSlotSymbol with: aBlock [
	"Adds the specified slot to transformations. Raises an error if the slot has already been added."

	self verifySlotDuplicationFor: aSlotSymbol.
	operations at: aSlotSymbol asString put: aBlock
]

{ #category : 'error' }
DSRecordDataFilter >> verifySlotDuplicationFor: aSlotSymbol [
	"Verifies that the specified slot symbol is not already added to prevent conflicts."

	(operations includesKey: aSlotSymbol asString) ifTrue: [ self error: 'A slot cannot be transformed twice.' ]
]

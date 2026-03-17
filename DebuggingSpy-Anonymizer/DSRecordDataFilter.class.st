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
DSRecordDataFilter class >> processRecords: someRecords with: aSelector [
	"Uses the method selector to apply a filter on every record."

	^ OrderedCollection new
		  addAll: (someRecords collect: [ :record | (record class lookupSelector: aSelector) valueWithReceiver: record ]);
		  yourself
]

{ #category : 'filtering' }
DSRecordDataFilter >> applyOn: aRecord [
	"Applies the filter on a deep copy of the specified record."

	| newRecord |
	newRecord := self getRecordCopyOf: aRecord.

	newRecord class allSlots do: [ :slot |
			operations
				at: slot name
				ifPresent: [ :block | slot write: (block value: (newRecord readSlotNamed: slot name)) to: newRecord ]
				ifAbsent: [ slot write: nil to: newRecord ] ].

	^ newRecord
]

{ #category : 'accessing' }
DSRecordDataFilter >> getRecordCopyOf: aRecord [
	"Returns a deep copy of the specified record."

	^ aRecord deepCopy
]

{ #category : 'filtering' }
DSRecordDataFilter >> hash: aSlotSymbol [
	"Transforms the specified slot's value in its hash."

	self transform: aSlotSymbol with: [ :anObject | anObject hash ]
]

{ #category : 'initialization' }
DSRecordDataFilter >> initialize [

	super initialize.
	operations := SmallDictionary new
]

{ #category : 'accessing' }
DSRecordDataFilter >> operations [

	^ operations
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

{ #category : 'filtering' }
DSRecordDataFilter >> with: aSlotSymbol [
	"Add the specified slot to the accepted slots. Raises an error if the specified slot has already been added."

	self verifySlotDuplicationFor: aSlotSymbol.
	operations at: aSlotSymbol asString put: [ :s | s ]
]

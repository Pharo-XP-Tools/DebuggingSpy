"
I am a class representing a data filter for Debugging Spy's records.
My api provides : 
- #with which ensures that the specified slot will be deepcopied into the new record.
- #transform which permits to define a specific transformation for the specified slot.
- #hash which uses the identityHash of the specified slot value.
Examples: 
filter := DSRecordDataFilter new with: #aSlot; transform: #aSlot with: [ :aValue | aValue ... ]; hash: #aSlot; yourself
I store all operations in a dedicated slot which is a SmallDictionary associating a slot to its operation, examples : 
	'aSlot' -> [ :aValue | aValue ] // with
	'aSlot' -> [ :aValue | aValue ... ] // transform
	'aSlot' -> [ :aValue | aValue identityHash ] // hash
	
When the filter is configured with all its operations, it can be applied on records as follows : 
	filteredRecord := aFilter applyOn: aRecord
	filteredRecords := DSRecordDataFilter processRecords: someRecords with: #aSelector // we assume that the selector applies a filter on a record and returns a record
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

	| newRecords |
	newRecords := OrderedCollection new.
	newRecords addAll: (someRecords collect: [ :record | (record class lookupSelector: aSelector) valueWithReceiver: record ]).

	^ newRecords
]

{ #category : 'filtering' }
DSRecordDataFilter >> applyOn: aRecord [
	"Applies the filter on the specified record and returns the resulting filtered record"

	| newRecord |
	newRecord := aRecord class new.

	aRecord class allSlots do: [ :slot |
			operations
				at: slot name asSymbol
				ifPresent: [ :block | slot write: (block value: (aRecord readSlotNamed: slot name)) to: newRecord ]
				ifAbsent: [ slot write: nil to: newRecord ] ].

	^ newRecord
]

{ #category : 'filtering' }
DSRecordDataFilter >> hash: aSlotSymbol [
	"Transforms the specified slot's value into its identityHash."

	self transform: aSlotSymbol with: [ :anObject | anObject identityHash ]
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
	"Adds the specified slot and its associated transformation in the operations."

	operations at: aSlotSymbol put: aBlock
]

{ #category : 'filtering' }
DSRecordDataFilter >> with: aSlotSymbol [
	"Add the specified slot as an accepted slot (with no transformation) in the operations."

	operations at: aSlotSymbol put: [ :s | s ]
]

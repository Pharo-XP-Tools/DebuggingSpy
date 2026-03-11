"
I am a class that represents a Debugging Spy record filter that excludes some parts of the data and keeps all the other ones.
"
Class {
	#name : 'DSRecordExcludeFilter',
	#superclass : 'DSRecordDataFilter',
	#category : 'DebuggingSpy-Anonymizer-filters',
	#package : 'DebuggingSpy-Anonymizer',
	#tag : 'filters'
}

{ #category : 'filtering' }
DSRecordExcludeFilter >> applyOn: aRecord [
	"Applies the filter on a deep copy of the specified record."

	| newRecord |
	newRecord := self getRecordCopyOf: aRecord.

	newRecord class allSlots do: [ :slot |
		operations at: slot name ifPresent: [ :block | slot write: (block value: (newRecord readSlotNamed: slot name)) to: newRecord ] ].

	^ newRecord
]

{ #category : 'filtering' }
DSRecordExcludeFilter >> without: aSlotSymbol [
	"Add the specified slot to the excluded slots. Raises an error if the specified slot has already been added."

	self verifySlotDuplicationFor: aSlotSymbol.
	operations at: aSlotSymbol asString put: [ :s | nil ]
]

"
I am a class that represents a Debugging Spy record filter that includes some parts of the data and excludes all the other ones.
"
Class {
	#name : 'DSRecordIncludeFilter',
	#superclass : 'DSRecordDataFilter',
	#category : 'DebuggingSpy-Anonymizer-filters',
	#package : 'DebuggingSpy-Anonymizer',
	#tag : 'filters'
}

{ #category : 'filtering' }
DSRecordIncludeFilter >> applyOn: aRecord [
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

{ #category : 'filtering' }
DSRecordIncludeFilter >> with: aSlotSymbol [
	"Add the specified slot to the accepted slots. Raises an error if the specified slot has already been added."

	self verifySlotDuplicationFor: aSlotSymbol.
	operations at: aSlotSymbol asString put: [ :s | s ]
]

Extension { #name : 'DSAbstractEventRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSAbstractEventRecord >> anonymize [

	self class allSlots do: [ :s | s write: nil to: self ]
]

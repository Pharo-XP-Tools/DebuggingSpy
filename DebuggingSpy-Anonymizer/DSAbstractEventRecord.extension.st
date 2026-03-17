Extension { #name : 'DSAbstractEventRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSAbstractEventRecord >> anonymize [
	"Self applies the anonymous filter and returns the anonymous record."

	^ self class anonymousFilter applyOn: self
]

{ #category : '*DebuggingSpy-Anonymizer' }
DSAbstractEventRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ DSRecordDataFilter new
		  with: #dateTime;
		  with: #uuid;
		  with: #windowId;
		  yourself
]

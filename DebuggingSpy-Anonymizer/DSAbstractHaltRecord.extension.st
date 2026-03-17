Extension { #name : 'DSAbstractHaltRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSAbstractHaltRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #method;
		  yourself
]

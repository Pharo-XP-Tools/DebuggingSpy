Extension { #name : 'DSHaltChangeRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSHaltChangeRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  with: #haltChange;
		  yourself
]

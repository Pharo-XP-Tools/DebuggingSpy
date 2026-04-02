Extension { #name : 'DSAbstractTaskRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSAbstractTaskRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  with: #task;
		  yourself
]

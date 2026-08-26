Extension { #name : 'DSTaskSuccessRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSTaskSuccessRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  with: #success;
		  yourself
]

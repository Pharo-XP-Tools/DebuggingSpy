Extension { #name : 'DSLoggingErrorRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSLoggingErrorRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  with: #event;
		  yourself
]

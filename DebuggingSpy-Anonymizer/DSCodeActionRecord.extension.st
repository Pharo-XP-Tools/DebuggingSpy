Extension { #name : 'DSCodeActionRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSCodeActionRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #selectedString;
		  yourself
]

Extension { #name : 'DSSurveyRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSSurveyRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #survey;
		  yourself
]

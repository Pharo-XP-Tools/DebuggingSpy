Extension { #name : 'DSHaltHitRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSHaltHitRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  with: #once;
		  with: #conditional;
		  with: #selector;
		  yourself
]

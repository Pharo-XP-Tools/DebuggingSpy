Extension { #name : 'DSMethodEventRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSMethodEventRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #methodName;
		  yourself
]

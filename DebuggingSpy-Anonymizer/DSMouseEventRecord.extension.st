Extension { #name : 'DSMouseEventRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSMouseEventRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  transform: #toolInfo with: [ :toolInfo | toolInfo anonymize ];
		  yourself
]

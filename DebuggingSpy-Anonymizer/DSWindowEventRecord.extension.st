Extension { #name : 'DSWindowEventRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSWindowEventRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  transform: #toolInfo with: [ :toolInfo | toolInfo anonymize ];
		  yourself
]

Extension { #name : 'DSWindowActivityRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSWindowActivityRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  transform: #start with: [ :event | event anonymize ];
		  transform: #stop with: [ :event | event anonymize ];
		  transform: #events with: [ :events | events do: [ :event | event anonymize ] ];
		  yourself
]

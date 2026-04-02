Extension { #name : 'DSUnhandledExceptionRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSUnhandledExceptionRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #exceptionClass;
		  hash: #method;
		  hash: #errorString;
		  hash: #node;
		  hash: #receiver;
		  yourself
]

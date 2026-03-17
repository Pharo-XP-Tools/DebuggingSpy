Extension { #name : 'DSClipboardActionRecord' }

{ #category : '*DebuggingSpy-Anonymizer' }
DSClipboardActionRecord class >> anonymousFilter [
	"Returns the data filter that anonymizes the record for this class"

	^ super anonymousFilter
		  hash: #clipboardText;
		  yourself
]

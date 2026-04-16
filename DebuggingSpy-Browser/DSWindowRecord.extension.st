Extension { #name : 'DSWindowRecord' }

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> ifWindow: aValue ifRecord: anotherValue [
	"If the object is a DSWindowRecord, returns aValue, and returns the other value otherwise."

	^ aValue
]

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> windowColor [
	"Returns the toolinfo associated window color, and the default color if undefined."

	^ DSRecordBrowserPresenter windowColorFrom: toolInfos
]

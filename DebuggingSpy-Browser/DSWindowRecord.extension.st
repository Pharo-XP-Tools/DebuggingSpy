Extension { #name : 'DSWindowRecord' }

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> windowColor [
	"Returns the toolinfo associated window color, and the default color if undefined."

	^ DSRecordBrowserPresenter windowColorFrom: toolInfos
]

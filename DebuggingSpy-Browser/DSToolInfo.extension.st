Extension { #name : 'DSToolInfo' }

{ #category : '*DebuggingSpy-Browser' }
DSToolInfo >> windowColor [
	"Returns the toolclass associated color, or the default color if undefined."

	^ DSRecordBrowserPresenter windowColorFrom: toolClass
]

Extension { #name : 'Object' }

{ #category : '*DebuggingSpy-Browser' }
Object class >> windowColor [
	"Returns the associated window color."

	<DSWindowColor>
	^ DSRecordBrowserPresenter defaultWindowColor
]

{ #category : '*DebuggingSpy-Browser' }
Object class >> windowType [
	"Returns the name of the window type."

	^ 'Unknown window'
]

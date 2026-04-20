Extension { #name : 'DSWindowRecord' }

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> printAsFormattedTime [
	"Returns the formatted time to be displayed in the windows presenter."

	^ nil
]

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> type [
	"Returns the window's type to be displayed in the windows presenter."

	^ self windowType , ' (' , events size asString , ' events)'
]

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> windowColor [
	"Returns the toolinfo associated window color, and the default color if undefined."

	^ DSRecordBrowserPresenter windowColorFrom: toolInfos
]

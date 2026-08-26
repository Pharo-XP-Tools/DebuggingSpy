Extension { #name : 'DSWindowRecord' }

{ #category : '*DebuggingSpy-Browser' }
DSWindowRecord >> printAsFormattedTime [
	"Returns the formatted time to be displayed in the windows presenter."

	| duration |
	duration := self totalTime.

	^ (String
		   new: 18
		   streamContents: [ :aStream |
		   (Time seconds: duration seconds nanoSeconds: duration nanoSeconds) print24: true showSeconds: true on: aStream ]) asText
		  allBold
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

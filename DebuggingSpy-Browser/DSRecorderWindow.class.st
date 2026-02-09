"
This class is a window displaying some informations while DebuggingSpy is recording.
"
Class {
	#name : 'DSRecorderWindow',
	#superclass : 'SystemWindow',
	#instVars : [
		'labelMorph',
		'running',
		'startTime',
		'timer'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'initialization' }
DSRecorderWindow >> buildUI [

	labelMorph := StringMorph new.
	labelMorph contents: '00:00:000'.
	labelMorph position: 10 @ 40.
	labelMorph extent: 230 @ 60.
	self addMorph: labelMorph
]

{ #category : 'initialization' }
DSRecorderWindow >> initialize [

	super initialize.
	running := false.
	self initializeProperties.
	self buildUI
]

{ #category : 'initialization' }
DSRecorderWindow >> initializeProperties [

	self
		setLabel: 'Debugging spy recorder';
		extent: self size;
		lock;
		"makeUnclosable;"
		"makeBorderless ;"
		beUnresizeable
]

{ #category : 'initialization' }
DSRecorderWindow >> makeButton: aLabel action: anAction [
    | btn |
    btn := PluggableButtonMorph new.
    btn label: aLabel.
    btn target: self.
    btn actionSelector: anAction.
    btn extent: 70@30.
    ^btn

]

{ #category : 'accessing' }
DSRecorderWindow >> margin [
	"Space around the window"

	^ 5 @ 32
]

{ #category : 'wiw support' }
DSRecorderWindow >> morphicLayerNumber [
	"To ensure the recorder window is always displayed at screen and cannot be covered"

	^ 12
]

{ #category : 'opening' }
DSRecorderWindow >> openInWorld [

	super openInWorld.
	self position: self currentWorld extent - self extent - self margin
]

{ #category : 'timer' }
DSRecorderWindow >> resetTimer [
    startTime := Time millisecondClockValue.
    labelMorph contents: '00:00:000'.

]

{ #category : 'accessing' }
DSRecorderWindow >> size [

	^ 150 @ 40
]

{ #category : 'timer' }
DSRecorderWindow >> startTimer [

	running ifTrue: [ ^ self ].

	startTime := Time millisecondClockValue.
	running := true.
	timer := [
		         [ running ] whileTrue: [
				         | elapsed minutes seconds milliseconds text |
				         elapsed := Time millisecondClockValue - startTime.

				         minutes := elapsed // 60000 \\ 60.
				         seconds := elapsed // 1000 \\ 60.
				         milliseconds := elapsed \\ 1000.

				         text := String streamContents: [ :s |
						                 s nextPutAll: (minutes printPaddedWith: $0 to: 2).
						                 s nextPut: $:.
						                 s nextPutAll: (seconds printPaddedWith: $0 to: 2).
						                 s nextPut: $:.
						                 s nextPutAll: (milliseconds printPaddedWith: $0 to: 3) ].

				         labelMorph contents: text.
				         (Delay forMilliseconds: 50) wait ] ] fork
]

{ #category : 'timer' }
DSRecorderWindow >> stopTimer [
    running := false.
]

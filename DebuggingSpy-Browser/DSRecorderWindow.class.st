"
This class is a window displaying some informations while DebuggingSpy is recording.
"
Class {
	#name : 'DSRecorderWindow',
	#superclass : 'SystemWindow',
	#instVars : [
		'timerMorph',
		'running',
		'startTime',
		'timer',
		'timeNowMorph'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'initialization' }
DSRecorderWindow >> buildUI [

	| recordingIcon stopButton |
	recordingIcon := ImageMorph new
		                 image: (self iconNamed: #glamorousRedCircle);
		                 position: 0 @ 7;
		                 yourself.

	timerMorph := StringMorph new
		              contents: '00:00:000';
		              position: 15 @ 6.

	timeNowMorph := StringMorph new
		                contents: Time now print24;
		                position: 75 @ 6.

	stopButton := PluggableButtonMorph new
		              label: (IconicListItemMorph new icon: (self iconNamed: #stop));
		              model: DSRecordBrowserPresenter presenterWindow presenter;
		              actionSelector: #stopRecording;
		              position: 125 @ 4;
		              yourself.

	self
		addMorph: recordingIcon;
		addMorph: timerMorph;
		addMorph: timeNowMorph;
		addMorph: stopButton
]

{ #category : 'initialization' }
DSRecorderWindow >> initialize [

	super initialize.
	running := false.
	self minimumExtent: self size.
	self initializeProperties.
	self buildUI
]

{ #category : 'initialization' }
DSRecorderWindow >> initializeProperties [

	self
		extent: self size;
		beSticky;
		makeUnclosable;
		removeLabelArea;
		removeBoxes;
		beUnresizeable
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

{ #category : 'initialization' }
DSRecorderWindow >> obuildUI [

	| recordingIcon stopButton |
	recordingIcon := ImageMorph new
		                 image: (self iconNamed: #glamorousRedCircle);
		                 position: 0 @ 7;
		                 yourself.

	timerMorph := StringMorph new
		              contents: '00:00:000';
		              position: 15 @ 6.

	timeNowMorph := StringMorph new
		                contents: Time now print24;
		                position: 75 @ 6.

	stopButton := PluggableButtonMorph new
		              icon: (self iconNamed: #stop);
		              position: 128 @ 6;
		              beIconTop;
		              "target: self;
		              actionSelector: #stopRecording;"yourself.

	self
		addMorph: recordingIcon;
		addMorph: timerMorph;
		addMorph: timeNowMorph;
		addMorph: stopButton
]

{ #category : 'opening' }
DSRecorderWindow >> openInWorld [

	super openInWorld.
	self position: self currentWorld extent - self extent - self margin
]

{ #category : 'accessing' }
DSRecorderWindow >> size [

	^ 150 @ 30
]

{ #category : 'timer' }
DSRecorderWindow >> startTimer [

	running ifTrue: [ ^ self ].

	startTime := Time millisecondClockValue.
	running := true.
	timer := [
		         [ running ] whileTrue: [
				         timerMorph contents: (Time millisecondClockValue - startTime) seconds asString.
				         timeNowMorph contents: Time now print24.
				         (Delay forMilliseconds: 50) wait ] ] fork
]

{ #category : 'timer' }
DSRecorderWindow >> stopTimer [

	running := false
]

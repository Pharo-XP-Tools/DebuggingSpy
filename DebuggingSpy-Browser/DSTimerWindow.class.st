"
This class is a window displaying some informations while DebuggingSpy is recording.
"
Class {
	#name : 'DSTimerWindow',
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
DSTimerWindow >> buildUI [
	"Builds the windows UI that contains : an icon that shows that Debugging Spy is recording, a chronometer, a timer that shows actual time and a stop recording button."

	timerMorph := self timerMorph.
	timeNowMorph := self timeNowMorph.

	self
		addMorph: self recordingIcon;
		addMorph: timerMorph;
		addMorph: timeNowMorph;
		addMorph: self stopButton
]

{ #category : 'resize/collapse' }
DSTimerWindow >> collapseOrExpand [

	^ self
]

{ #category : 'timer' }
DSTimerWindow >> elapsedTime [
	"Returns the elapsed time since the timer's start."

	^ Time current asSeconds - startTime
]

{ #category : 'initialization' }
DSTimerWindow >> initialize [

	super initialize.
	running := false.
	self minimumExtent: self size.
	self initializeProperties.
	self buildUI
]

{ #category : 'initialization' }
DSTimerWindow >> initializeProperties [

	self
		setLabel: 'DSSpy recorder';
		extent: self size;
		beSticky;
		makeUnclosable;
		removeLabelArea;
		removeBoxes;
		beUnresizeable
]

{ #category : 'accessing' }
DSTimerWindow >> margin [
	"Space around the window"

	^ 5 @ 32
]

{ #category : 'wiw support' }
DSTimerWindow >> morphicLayerNumber [
	"To ensure the recorder window is always displayed at screen and cannot be covered"

	^ 12
]

{ #category : 'opening' }
DSTimerWindow >> openInWorld [

	super openInWorld.
	self position: self currentWorld extent - self extent - self margin
]

{ #category : 'layout' }
DSTimerWindow >> recordingIcon [
	"Instanciates a new icon that shows that Debugging Spy is recording."

	^ ImageMorph new
		  image: (self iconNamed: #glamorousRedCircle);
		  position: 0 @ 7;
		  yourself
]

{ #category : 'accessing' }
DSTimerWindow >> size [

	^ 150 @ 30
]

{ #category : 'timer' }
DSTimerWindow >> startTimer [

	running ifTrue: [ ^ self ].

	startTime := Time current asSeconds.
	running := true.
	timer := [
		         [ running ] whileTrue: [
				         timerMorph contents: (Time fromSeconds: self elapsedTime) print24.
				         timeNowMorph contents: Time now print24.
				         (Delay forMilliseconds: 50) wait ] ] fork
]

{ #category : 'layout' }
DSTimerWindow >> stopButton [
	"Instanciates a new morph button that stops the recording and closes the window when clicked."

	^ PluggableButtonMorph new
		  label: (IconicListItemMorph new icon: (self iconNamed: #stop));
		  model: DSRecordBrowser uniqueInstance;
		  actionSelector: #stopRecording;
		  position: 125 @ 4;
		  yourself
]

{ #category : 'timer' }
DSTimerWindow >> stopTimer [

	running := false
]

{ #category : 'layout' }
DSTimerWindow >> timeNowMorph [
	"Instanciates a new morph that shows the actual time."

	^ StringMorph new
		  contents: Time now print24;
		  position: 75 @ 6
]

{ #category : 'layout' }
DSTimerWindow >> timerMorph [
	"Insanciates a new morph that contains the seconds timer on the window."

	^ StringMorph new
		  contents: '00:00:000';
		  position: 15 @ 6
]

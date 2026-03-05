"
I am a window displaying timer while DebuggingSpy is recording.
"
Class {
	#name : 'DSTimerWindow',
	#superclass : 'SystemWindow',
	#instVars : [
		'timerMorph',
		'startTime',
		'currentTimeMorph'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'initialization' }
DSTimerWindow >> buildUI [
	"Builds the windows UI, it contains : an icon which shows that Debugging Spy is recording, a chronometer, a timer with current time and a stop recording button."

	timerMorph := self timerMorph.
	currentTimeMorph := self currentTimeMorph.

	self
		addMorph: self recordingIcon;
		addMorph: timerMorph;
		addMorph: currentTimeMorph;
		addMorph: self stopButton
]

{ #category : 'resize/collapse' }
DSTimerWindow >> collapseOrExpand [

	^ self
]

{ #category : 'layout' }
DSTimerWindow >> currentTimeMorph [
	"Instanciates a new morph that shows the actual time."

	^ StringMorph new
		  contents: Time now print24;
		  position: 75 @ 6
]

{ #category : 'timer' }
DSTimerWindow >> elapsedTime [
	"Returns the elapsed time since the timer's start."

	startTime ifNil: [ ^ 0 ].
	^ Time current asSeconds - startTime
]

{ #category : 'initialization' }
DSTimerWindow >> initialize [

	super initialize.
	self minimumExtent: self size.
	self initializeProperties.
	self buildUI.
	self initializeTimers
]

{ #category : 'initialization' }
DSTimerWindow >> initializeProperties [

	self
		setLabel: 'DSSpy timer';
		extent: self size;
		beSticky;
		makeUnclosable;
		removeLabelArea;
		removeBoxes;
		beUnresizeable
]

{ #category : 'initialization' }
DSTimerWindow >> initializeTimers [
	"Creates a new process that displays the current time even if the timer is not started. The timer would be updated whenever the record session starts."

	[
		[ true ] whileTrue: [
				DSSpy recordingSession ifTrue: [ timerMorph contents: (Time fromSeconds: self elapsedTime) print24 ].
				currentTimeMorph contents: Time now print24.
				(Delay forMilliseconds: 50) wait ] ] fork
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
	"Starts a new process for the timer."

	DSSpy recordingSession ifFalse: [ ^ self ].
	startTime := Time current asSeconds
]

{ #category : 'layout' }
DSTimerWindow >> stopButton [
	"Instanciates a new morph button that stops the recording and closes the window when clicked."

	^ PluggableButtonMorph new
		  label: (IconicListItemMorph new icon: (self iconNamed: #stop));
		  model: DSRecordBrowserPresenter uniqueInstance;
		  actionSelector: #stopRecording;
		  position: 125 @ 4;
		  yourself
]

{ #category : 'layout' }
DSTimerWindow >> timerMorph [
	"Insanciates a new morph that contains the seconds timer on the window."

	^ StringMorph new
		  contents: '00:00:000';
		  position: 15 @ 6
]

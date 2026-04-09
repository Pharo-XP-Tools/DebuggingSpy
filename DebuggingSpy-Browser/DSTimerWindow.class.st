"
I am a window displaying timer while DebuggingSpy is recording.
"
Class {
	#name : 'DSTimerWindow',
	#superclass : 'SystemWindow',
	#instVars : [
		'timerMorph',
		'startTime',
		'currentTimeMorph',
		'lastEventMorph',
		'lastToolInfo'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'initialization' }
DSTimerWindow >> buildLayout [
	"Builds the windows layout, it contains : an icon which shows that Debugging Spy is recording, a chronometer, a timer with current time and a stop recording button."

	timerMorph := self timerMorph.
	currentTimeMorph := self currentTimeMorph.
	lastEventMorph := self lastEventMorph.

	self
		addMorph: lastEventMorph;
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
		  position: 325 @ 6
]

{ #category : 'timer' }
DSTimerWindow >> elapsedTime [
	"Returns the elapsed time since the timer's start."

	startTime ifNil: [ ^ 0 ].
	^ Time current asSeconds - startTime
]

{ #category : 'accessing' }
DSTimerWindow >> getFormattedNameFrom: aRecord [
	"Returns the event name followed by the tool class (or the last one), if applicable."

	| toolInfo formattedEventName |
	formattedEventName := aRecord eventName.

	toolInfo := self getToolInfoFor: aRecord.
	toolInfo ifNotNil: [ formattedEventName := formattedEventName , ' (' , toolInfo toolClassName asString , ')' ].

	^ formattedEventName
]

{ #category : 'accessing' }
DSTimerWindow >> getToolInfoFor: aRecord [
	"Returns the record's toolInfo if possible, else returns the last used toolInfo (which can be nil)."

	| toolInfo |
	(aRecord class hasSlotNamed: 'toolInfo') ifFalse: [ ^ lastToolInfo ].

	toolInfo := aRecord readSlotNamed: 'toolInfo'.
	toolInfo ifNotNil: [ lastToolInfo := toolInfo ].
	^ lastToolInfo
]

{ #category : 'initialization' }
DSTimerWindow >> initialize [

	super initialize.
	self minimumExtent: self size.
	self initializeProperties.
	self buildLayout.
	self initializeTimers.
	self listenToWindowEvents
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

{ #category : 'layout' }
DSTimerWindow >> lastEventMorph [
	"Instanciates a new morph that shows the last event."

	^ lastEventMorph ifNil: [
			  lastEventMorph := StringMorph new
				                    contents: 'No last record';
				                    position: 5 @ 6 ]
]

{ #category : 'accessing' }
DSTimerWindow >> lastRecord: aRecord [
	"Updates the last record text on the window."

	lastEventMorph contents: (self getFormattedNameFrom: aRecord)
]

{ #category : 'accessing' }
DSTimerWindow >> lastToolInfo [

	^ lastToolInfo
]

{ #category : 'accessing' }
DSTimerWindow >> lastToolInfo: aToolInfo [

	lastToolInfo := aToolInfo
]

{ #category : 'windows' }
DSTimerWindow >> listenToWindowEvents [
	"Listens to window events announcer to update the timer window position when needed."

	self currentWorld announcer when: WindowOpened send: #updatePosition to: self.
	self currentWorld announcer when: WindowClosed send: #updatePosition to: self.
	self currentWorld announcer when: WindowActivated send: #updatePosition to: self
]

{ #category : 'accessing' }
DSTimerWindow >> margin [
	"Space around the window"

	^ 5 @ 5
]

{ #category : 'wiw support' }
DSTimerWindow >> morphicLayerNumber [
	"To ensure the recorder window is always displayed at screen and cannot be covered"

	^ 12
]

{ #category : 'layout' }
DSTimerWindow >> recordingIcon [
	"Instanciates a new icon that shows that Debugging Spy is recording."

	^ ImageMorph new
		  image: (self iconNamed: #glamorousRedCircle);
		  position: 250 @ 7;
		  yourself
]

{ #category : 'accessing' }
DSTimerWindow >> size [

	^ 400 @ 30
]

{ #category : 'accessing' }
DSTimerWindow >> startTime [

	^ startTime
]

{ #category : 'accessing' }
DSTimerWindow >> startTime: aNumberOfSeconds [

	startTime := aNumberOfSeconds
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
		  model: self;
		  actionSelector: #stopTimer;
		  position: 375 @ 4;
		  yourself
]

{ #category : 'recording' }
DSTimerWindow >> stopTimer [
	"Stops the recording."

	DSRecordBrowserPresenter uniqueInstance stopRecording
]

{ #category : 'layout' }
DSTimerWindow >> timerMorph [
	"Insanciates a new morph that contains the seconds timer on the window."

	^ StringMorph new
		  contents: '00:00:00';
		  position: 265 @ 6
]

{ #category : 'private - layout' }
DSTimerWindow >> updatePosition [
	"Sets the timer window position above the taskbar."

	self position: self currentWorld extent - self extent - self margin - (0 @ self currentWorld taskbars first extent y)
]

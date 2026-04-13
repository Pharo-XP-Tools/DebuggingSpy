Class {
	#name : 'DSTimerWindowTest',
	#superclass : 'TestCase',
	#instVars : [
		'timerWindow'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'layout' }
DSTimerWindowTest >> currentTimeMorph [
	"Returns the window's timeNowMorph"

	^ timerWindow readSlot: (DSTimerWindow slotNamed: #currentTimeMorph)
]

{ #category : 'running' }
DSTimerWindowTest >> setUp [
	super setUp.
	
	timerWindow := DSTimerWindow new.
]

{ #category : 'tests' }
DSTimerWindowTest >> testBuildLayout [
	"buildLayout has been already called from initialize"

	| submorphs |
	submorphs := timerWindow submorphs.

	self assert: ({ 'timerMorph'. 'currentTimeMorph'. 'lastEventMorph'. 'windowColorIndicator' } allSatisfy: [ :slotName |
			 (timerWindow readSlotNamed: slotName) isNotNil ]).

	self assert: submorphs size equals: 6.
	self assert: (submorphs last class = StringMorph and: submorphs last contents = '  ').
	self assert: ((submorphs at: 5) class = StringMorph and: (submorphs at: 5) contents = 'No last record').
	self assert: ((submorphs at: 4) class = ImageMorph and: (submorphs at: 4) form = (self iconNamed: #glamorousRedCircle)).
	self assert: ((submorphs at: 3) class = StringMorph and: (submorphs at: 3) contents = '00:00:00').
	self assert: (submorphs second class = StringMorph and: submorphs second contents = Time current print24).
	self assert: (submorphs first class = PluggableButtonMorph and: submorphs first label class = IconicListItemMorph)
]

{ #category : 'tests' }
DSTimerWindowTest >> testCurrentTimeMorph [

	self assert: (Time readFrom: self currentTimeMorph contents readStream) asSeconds equals: Time now asSeconds
]

{ #category : 'tests' }
DSTimerWindowTest >> testElapsedTime [

	DSSpy recordingSession: true.
	timerWindow startTimer.

	(Delay forMilliseconds: 1000) wait.

	DSSpy recordingSession: false.
	self assert: timerWindow elapsedTime equals: 1
]

{ #category : 'tests' }
DSTimerWindowTest >> testEmptyTimerMorph [

	self assert: (Time readFrom: self timerMorph contents readStream) seconds equals: 0
]

{ #category : 'tests' }
DSTimerWindowTest >> testGetFormattedNameFrom [

	| toolInfo |
	toolInfo := DSToolInfo new toolClass: self class.

	self assert: (timerWindow getFormattedNameFrom: DSBrowseRecord new) equals: 'Browse'.
	self
		assert: (timerWindow getFormattedNameFrom: (DSMouseEnterWindowRecord new toolInfo: toolInfo))
		equals: 'Enter window (DSTimerWindowTest)'.
	self assert: (timerWindow getFormattedNameFrom: DSBrowseRecord new) equals: 'Browse (DSTimerWindowTest)'
]

{ #category : 'tests' }
DSTimerWindowTest >> testGetRecordColorFrom [

	| toolInfo |
	toolInfo := DSToolInfo new toolClass: StPlayground.

	self assert: (timerWindow getRecordColorFrom: DSAbstractEventRecord new) equals: (Color fromHexString: '#b3b3b3').

	self
		assert: (timerWindow getRecordColorFrom: (DSMouseEventRecord new toolInfo: toolInfo))
		equals: (Color fromHexString: '#70B77E')
]

{ #category : 'tests' }
DSTimerWindowTest >> testGetToolInfoFor [

	| toolInfo record |
	self assert: (timerWindow getToolInfoFor: DSAbstractEventRecord new) isNil.

	toolInfo := DSToolInfo new toolClass: self class.
	record := DSMouseEnterWindowRecord new
		          toolInfo: toolInfo;
		          yourself.

	self assert: (timerWindow getToolInfoFor: record) equals: toolInfo.
	self assert: timerWindow lastToolInfo equals: toolInfo
]

{ #category : 'tests' }
DSTimerWindowTest >> testLastEventMorph [

	| eventMorph |
	eventMorph := timerWindow lastEventMorph.
	self assert: eventMorph contents equals: 'No last record'
]

{ #category : 'tests' }
DSTimerWindowTest >> testLastRecord [

	| record |
	record := DSBrowseRecord new.
	timerWindow lastRecord: record.
	self assert: timerWindow lastEventMorph contents equals: 'Browse'
]

{ #category : 'tests' }
DSTimerWindowTest >> testStartTimer [

	self assert: timerWindow startTimer equals: timerWindow.

	DSSpy recordingSession: true.

	timerWindow startTimer.
	self deny: timerWindow startTime isNil.

	DSSpy recordingSession: false
]

{ #category : 'tests' }
DSTimerWindowTest >> testWindowColorIndicator [

	timerWindow writeSlotNamed: 'windowColorIndicator' value: nil.
	self assert: timerWindow windowColorIndicator isNotNil.
	self assert: (timerWindow readSlotNamed: 'windowColorIndicator') isNotNil
]

{ #category : 'layout' }
DSTimerWindowTest >> timerMorph [
	"Returns the window's timerMorph."

	^ timerWindow readSlot: (DSTimerWindow slotNamed: #timerMorph)
]

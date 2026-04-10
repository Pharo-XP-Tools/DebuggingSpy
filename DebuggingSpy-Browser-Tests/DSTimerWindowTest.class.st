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

	self assert: ({ 'timerMorph'. 'currentTimeMorph'. 'lastEventMorph'. 'windowColorIndicator' } allSatisfy: [ :slotName |
			 (timerWindow readSlotNamed: slotName) isNotNil ]).

	self assert: timerWindow submorphs size equals: 6
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

	self assert: (timerWindow getRecordColorFrom: DSAbstractEventRecord new) equals: DSRecordBrowserPresenter defaultWindowColor.

	self assert: (timerWindow getRecordColorFrom: (DSMouseEventRecord new toolInfo: toolInfo)) equals: StPlayground windowColor
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
DSTimerWindowTest >> testUpdatePosition [

	| newPosition |
	newPosition := self currentWorld extent - timerWindow extent - timerWindow margin
	               - (0 @ self currentWorld taskbars first extent y).
	
	timerWindow updatePosition.
	self assert: timerWindow position equals: newPosition
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

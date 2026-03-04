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
DSTimerWindowTest >> testTimeNowMorph [

	self assert: (Time readFrom: self currentTimeMorph contents readStream) asSeconds equals: Time now asSeconds
]

{ #category : 'layout' }
DSTimerWindowTest >> timerMorph [
	"Returns the window's timerMorph."

	^ timerWindow readSlot: (DSTimerWindow slotNamed: #timerMorph)
]

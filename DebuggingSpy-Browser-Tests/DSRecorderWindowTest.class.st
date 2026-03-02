Class {
	#name : 'DSRecorderWindowTest',
	#superclass : 'TestCase',
	#instVars : [
		'window'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'running' }
DSRecorderWindowTest >> setUp [
	super setUp.
	
	window := DSTimerWindow new.
]

{ #category : 'tests' }
DSRecorderWindowTest >> testEmptyTimerWindow [

	self assert: (Time readFrom: self timerMorph contents readStream) seconds equals: 0
]

{ #category : 'tests' }
DSRecorderWindowTest >> testTimeNow [

	self assert: (Time readFrom: self timeNowMorph contents readStream) asSeconds equals: Time now asSeconds
]

{ #category : 'tests' }
DSRecorderWindowTest >> testTimer [

	window startTimer.
	(Delay forMilliseconds: 1000) wait.
	window stopTimer.
	self assert: window elapsedTime equals: 1
]

{ #category : 'layout' }
DSRecorderWindowTest >> timeNowMorph [
	"Returns the window's timeNowMorph"

	^ window readSlot: (DSTimerWindow slotNamed: #timeNowMorph)
]

{ #category : 'layout' }
DSRecorderWindowTest >> timerMorph [
	"Returns the window's timerMorph."

	^ window readSlot: (DSTimerWindow slotNamed: #timerMorph)
]

Class {
	#name : 'DSRecorderWindowTest',
	#superclass : 'TestCase',
	#instVars : [
		'recorder'
	],
	#category : 'DebuggingSpy-Browser-Tests',
	#package : 'DebuggingSpy-Browser-Tests'
}

{ #category : 'running' }
DSRecorderWindowTest >> setUp [
	super setUp.
	
	recorder := DSRecorderWindow new.
]

{ #category : 'tests' }
DSRecorderWindowTest >> testTimer [

	recorder startTimer.
	(Delay forMilliseconds: 1000) wait.
	recorder stopTimer.
	self assert: recorder timeElapsed equals: 1
]

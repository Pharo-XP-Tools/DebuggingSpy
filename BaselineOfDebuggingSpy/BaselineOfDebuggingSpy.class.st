Class {
	#name : #BaselineOfDebuggingSpy,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggingSpy
}

{ #category : #baselines }
BaselineOfDebuggingSpy >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec postLoadDoIt: #postloadAction.
		spec package: 'DebuggingSpy'.
		spec package: 'DebuggingSpy-Tests' ]
]

{ #category : #baselines }
BaselineOfDebuggingSpy >> postloadAction [
	DSSpy handlingError: false
]

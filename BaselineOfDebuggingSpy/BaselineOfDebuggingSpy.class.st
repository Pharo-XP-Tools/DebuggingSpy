Class {
	#name : 'BaselineOfDebuggingSpy',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDebuggingSpy',
	#package : 'BaselineOfDebuggingSpy'
}

{ #category : 'baselines' }
BaselineOfDebuggingSpy >> baseline: spec [

	<baseline>
	spec baseline: 'ExperimentModel' with: [ spec repository: 'github://Pharo-XP-Tools/ExperimentModel:main' ].

	spec for: #common do: [
			spec postLoadDoIt: #postloadAction.
			spec package: 'DebuggingSpy'.
			spec package: 'DebuggingSpy-Tests'.
			spec package: 'DebuggingSpy-Browser'.
			spec package: 'DebuggingSpy-Browser-Tests'.
			spec package: 'DebuggingSpy-Anonymizer'.
			spec package: 'DebuggingSpy-Anonymizer-Tests' ]
]

{ #category : 'baselines' }
BaselineOfDebuggingSpy >> postloadAction [

	DSSpy handlingError: false.
	KMRepository reset
]

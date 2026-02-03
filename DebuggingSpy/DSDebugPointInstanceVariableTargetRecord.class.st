"
I am a class that reprensent instance variable target record for debugPoint.
"
Class {
	#name : 'DSDebugPointInstanceVariableTargetRecord',
	#superclass : 'DSDebugPointClassTargetRecord',
	#instVars : [
		'accessStrategy'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'accessing' }
DSDebugPointInstanceVariableTargetRecord >> accessStrategy [ 

	^ accessStrategy 
]

{ #category : 'actions api' }
DSDebugPointInstanceVariableTargetRecord >> record: aDebugPointTarget [

	super record: aDebugPointTarget.
	accessStrategy := aDebugPointTarget accessStrategy 
]
